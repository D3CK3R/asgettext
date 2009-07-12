#!/usr/bin/env ruby

require 'pathname'

class ToGettext
    
    def update
        self.check_4_src_dir
        # create new .po file
        self.update_po
        self.update_translation_pot
        # merge changes with all translation files
        srcFile = self.dest+"messages.po"
        Dir[self.dest+"locale/**/messages.pot"].each { |potFile|
            exec("msgmerge --update --no-wrap --backup=numbered %s %s"%[potFile])
        }
    end

    def update_po
        tmpFiles = []
        
        # create intermediate files for parsing with gettext
        ARGV.each { |fileType|
            Dir['**/*.'+fileType].each { |path|
                infile = File.new(path, 'r')
                outfile = File.new(path+".pox", 'w')
                tmpFiles.push path+".pox"
                infile.each { |line|
                    # feed the mxml comments
                    #if line =~ /\{(.*?_\(.*?\)).*?\}/
                    #    puts $~[1]
                    # feed a normal assignment
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
        outputFile      = self.dest+"messages.po"

        # run gettext
        puts exec("xgettext -a --force-po -L Python --from-code=UTF-8 --no-wrap --output=%s --files-from=%s"%[outputFile, gettextFileList])
        File.delete("gettext_input.list")
        
        # cleanup tmp files
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
                File.copy(srcFile, destFile)
            end
            # merge the changes in messages.po to the pot translator file
            exec("msgmerge --backup=numbered --no-wrap %s %s"%[destFile, srcFile])
        }
    end
 

    # =============================================================================
    
    def init
        self.check_4_src_dir
        self.create_dir_if_not_exist self.dest+"/translation"
        self.create_dir_if_not_exist self.dest+"locale"
        if not File.exist? self.dest+"locale/en"
            self.create_translation_dir("en")
        end
    end

    def create_dir_if_not_exist(path)
        if not File.exist? path
            Dir.mkdir path
        end
    end

    def check_4_src_dir
        self.parse_dest_dir
        # check if we are in a flex dir
        if not Dir['*'].member? 'src'
            puts "This not a valid flex / actionscript project folder"
            puts "   'src' Folder doesn't exist"
            puts "    - use the '- d' option to specify another destination folder"
            puts "    - chane to a flex-project folder and execute the script there"
            help
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
            self.help
        elsif not File.directory? self.dest
            puts "Given destination '%s' is a file not a folder!" % self.dest
            self.help
        end
    end

    # =============================================================================
    
    def compile
        Dir[self.dest+"translation/locale/*/MESSAGES_LC/message.po"].each { |file|
            exec("msgfmt %s"%file)
        }
    end

    # =============================================================================
    
    def add
        self.check_4_src_dir
        if ARGV.length == 0
            puts "No language provided. \n use: togettext help"
            help
        elsif ARGV[0].length > 2
            puts "'%s' is not a valid language identifier!" % ARGV[0]
            help
        end
        self.create_translation_dir ARGV[0]
        if not self.po_exists?
            puts "messages.po doesn't exist yet!"
            puts "use 'togettext update' to update the messages.po and the translation files"
            help
        end
    end

    def create_translation_dir(lang)
        if File.exist? self.dest+"locale/"+lang
            puts "Translation for language='%s' exists already!"%lang
            self.help
        end
        self.create_dir_if_not_exist self.dest+"locale/"+lang
        self.create_dir_if_not_exist self.dest+"locale/"+lang+"/LC_MESSAGES"
        inputFile  = self.dest+"messages.po"
        outputFile = self.dest+"locale/"+lang+"/LC_MESSAGES/messages.pot"
        exec("msginit --no-wrap --input=%s --output=%s"%[inputFile, outputFile])
    end

    # =============================================================================
    
    def help
        puts
        version
        if ARGV.length == 0
            puts
            puts "    Type 'help <subcommand>' for help on a specific subcommand" 
            puts
            puts "    Available sucommands:"
            $subcommands.each { |symbol| puts " "*8+symbol.to_s }
        end
        exit
    end
    
    # =============================================================================
    
    def version
        puts "togettext a little translation helper for flex apps"
    end
    
    
    # ============================================================================
    def run
        self.check_for_gettext
        $subcommands = [
            :help,
            :init,
            :update,
            :add,
            :compile
        ]
        
        command =  ARGV.shift
        $subcommands.each{ |symbol|
            if symbol.to_s == command
                self.method(symbol).call
                exit
            end
        }
        # otherwise call the help
        puts "Unknown sucommand "+command.to_s
        puts 
        self.help
    end

    def check_for_gettext
        
    end
end


toGettext = ToGettext.new()
toGettext.run()
