#!/usr/bin/env ruby

require 'pathname'
require 'ftools'
require "open3"

class ToGettext
    
    def initialize
        @subcommands = Hash[
            :help,    Hash[:inline, "help [<subcommand>]  display help about a subcommand or this overview",
                           :help,   "displays a help dialog"],
            
            :init,    Hash[:inline, "init                 initialize the project structure",
                           :help,   "Creates the directory structure needed for running gettext.\n"+
                                    "The created directories are ./translation/{locale, translation}.\n"+
                                    "Usually you want to update the translation files using update so directly\n"+
                                    "type \"asgettext.rb init update\""],
            
            :update,  Hash[:inline, "update               the translation strings",
                           :help,   "Syncs the existing translation files with the sources.\n"+
                                    "Usually you want to compile again, so type directly \"asgettext.rb update compile\""],
            
            :add,     Hash[:inline, "add <lang>           add a new translation language",
                           :help,   "Add a new language. Creates the needed ddirectory structure.\n"+
                                    "<lang> is a two letter language code."],
            
            :compile, Hash[:inline, "compile             create the binaries ready for distribution",
                           :help,   "Creates the .mo files from all the .pot files. That is what you finally will\n"+
                                    "distribute on your server."],
            
            :translate,Hash[:inline,"translate <lang>    auto translate using google",
                            :help,  "Translates the .po file for the given language using "]
        ]
    end

    # ========================================================================
    
    def update
        # create / update new root .po file
        self.update_po
        self.update_translation_pot
    end

    def update_po
        tmpFiles = []
        if ARGV.length == 0
            ARGV[0] = "as"
            ARGV[1] = "mxml"
        end
        # create intermediate files for parsing with gettext
        ARGV.each { |fileType|
            Dir[@dest+'/src/**/*.'+fileType].each { |path|
                infile = File.new(path, 'r')
                outfile = File.new(path+".pox", 'w')
                tmpFiles.push path+".pox"
                infile.each { |line|
                    # feed a normal assignment
                    # TODO add parenthesis counting check here
                    # TODO add multiple matches per line
                    if line =~ /(_\(.*?\))/
                        outfile.puts $~[1]
                    end
                }
                outfile.close
            }
        }
        
        # write file list
        gettextFileList = self.dest+"gettext_input.list"
        gettext         = File.new(gettextFileList, 'w')
        tmpFiles.each { |path| gettext.puts path }
        gettext.close

        # run gettext
        outputFile      = self.dest+"messages.po"
        system("xgettext --extract-all --force-po --from-code=utf-8 --language=Python --no-wrap --output=%s --files-from=%s"%[outputFile, gettextFileList])
            
        # make sure we enforce UFT-8!
        # TODO

        # cleanup tmp files
        File.delete gettextFileList
        tmpFiles.each { |file|
            File.delete(file)
        }
    end

    def update_translation_pot
        if not self.po_exists?
            return
        end   
        Dir[self.dest+"locale/*/LC_MESSAGES/"].each { |path|
            destFile = path+"messages.pot"
            srcFile  = self.dest+"messages.po"
            if not File.exist? path+"messages.pot"
                self.create_translation_pot( path.match(/.*?\/locale\/([a-z_]{2})\/.*/)[1] )
            end
            # merge the changes in messages.po to the pot translator file
            system("msgmerge --force-po --update --backup=numbered --no-wrap %s %s"%[destFile, srcFile])
        }
    end

    def po_exists?
        return File.exist?(self.dest+"messages.po")
    end

    # =============================================================================
    
    def init
        self.create_dir_if_not_exist self.dest+"/translation"
        self.create_dir_if_not_exist self.dest+"locale"
        if not File.exist? self.dest+"locale/en"
            self.create_translation_dir("en")
        end
    end

    def create_dir_if_not_exist(path)
        if not File.exist? path
            `mkdir -p #{path}`
        end
    end

    def check_4_src_dir
        self.parse_dest_dir
        # check if we are in a flex dir
        if not Dir['*'].member? 'src'
            puts "This not a valid flex / actionscript project folder"
            puts "   'src' Folder doesn't exist"
            puts "    - use the '--dest' option to specify another destination folder"
            puts "    - chane to a flex-project folder and systemute the script there"
            self.help_stop
        end 
    end

    def parse_dest_dir
        ARGV.length.times { |i|
            arg = ARGV[i]
            if arg == "-d" or arg == "--dest"
                @dest = Pathname.new(ARGV[i+1]).realpath.to_s
                # remove these arguments from ARGV
                ARGV.delete_at(i)
                ARGV.delete_at(i+1)
                self.check_dest_dir
                return
            end
        }
        @dest = Pathname.new('.').realpath.to_s
    end

    def dest
        return @dest+"/translation/"
    end

    def check_dest_dir
        if not File.exist? self.dest
            puts "Folder '%s' doesn't exist!" % self.dest
            self.help_stop
        elsif not File.directory? self.dest
            puts "Given destination '%s' is a file not a folder!" % self.dest
            self.help_stop
        end
    end

    # =============================================================================
    
    def compile
        Dir[self.dest+"locale/**/messages.pot"].each { |file|
            outputFile = File.dirname(file) + "/messages.mo"
            system("msgfmt --strict --use-fuzzy --output=%s %s" % [outputFile, file])
        }
    end

    # =============================================================================
    
    def add
        if ARGV.length == 0
            puts "No language provided. \n use: togettext help"
            self.help_stop(:add)
        elsif ARGV[0].length > 2
            puts "'%s' is not a valid language identifier!" % ARGV[0]
            self.help_stop(:add)
        end
        self.create_translation_dir ARGV[0]
        if not self.po_exists?
            puts "messages.po doesn't exist yet!"
            puts "use 'togettext update' to update the messages.po and the translation files"
            self.help_stop
        end
    end

    def create_translation_dir(lang)
        if File.exist? self.dest+"locale/"+lang
            puts "Translation for language='%s' exists already!"%lang
            self.help_stop
        end
        self.create_dir_if_not_exist self.dest+"locale/"+lang
        self.create_dir_if_not_exist self.dest+"locale/"+lang+"/LC_MESSAGES"
        self.create_translation_pot lang
    end

    def create_translation_pot(lang)
        inputFile  = self.dest+"messages.po"
        outputFile = self.dest+"locale/"+lang+"/LC_MESSAGES/messages.pot"
        system("msginit --no-wrap --input=%s --output=%s"%[inputFile, outputFile])
    end

    # =============================================================================
    
    def translate
        if ARGV.length == 0
            puts "No language given to translate."
            self.help_stop(:translate)
        end
    end
    
    # =============================================================================
    
    def help_stop(subcommand=nil)
        if subcommand == nil
            puts "Use 'help <subcommand>' for help on a specific subcommand" 
        else
            self.print_help(subcommand)
        end
        exit
    end

    def help
        #self.version
        if ARGV.length == 0
            puts "Use 'help <subcommand>' for help on a specific subcommand" 
            puts "Available sucommands:"
            @subcommands.each_pair { |symbol,desc| 
                puts "#{" "*4} #{desc[:inline]}" 
            }
        elsif @subcommands.has_key? ARGV[0].intern
            self.print_help(ARGV[0].intern)
        else
            puts "Unknown help topic \"#{ARGV.shift}\""
            self.help
        end
    end
   
    def print_help(subcommand)
        @subcommands[subcommand][:help].split("\n").each { |line|
            puts " "*4+line
        }
    end

    # =============================================================================
    
    def version
        puts "asgettext a little translation helper for flex apps"
    end
    
    
    # ============================================================================
    def run
        self.check_for_gettext
        self.check_4_src_dir
        command =  ARGV.shift
        # explicitely loop here to allow something like "update compile"
        @subcommands.keys.each{ |symbol|
            if symbol.to_s == command
                self.method(symbol).call
                exit
            end
        }
        # otherwise call the help
        puts "Unknown subcommand \"#{command.to_s}\"."
        self.help
    end

    def check_for_gettext
        ['xgettext', 'msginit', 'msgfmt', 'msgmerge'].each{ |command|
            Open3.popen3(command+' --help') { |stdin, stdout, stderr|
                if stderr.read.length > 0
                    puts "Your gettext installation is incomplete: '%s' is missing"%command
                    puts "Download an install gettext:"
                    if RUBY_PLATFORM.include? "linux"
                        puts "    sudo apt-get install gettext"
                    elsif RUBY_PLATFORM.include? "darwin"
                        puts "    get macports from www.macports.org"
                        puts "    then open Terminal.app and type: sudo port install gettext"
                    else
                        puts "    go to ftp://ftp.gnu.org/gnu/gettext/ and look for *.woe32.zip"  
                    end
                    exit
                end
            }
        }
    end
end


toGettext = ToGettext.new()
toGettext.run()
