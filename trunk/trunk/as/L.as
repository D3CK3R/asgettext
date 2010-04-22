package language
{
	import gettext.GetText;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.Application;
	import mx.core.FlexGlobals;
	
	[Event(name="loaded", type="flash.events.Event")]
	public class L extends EventDispatcher
	{
	    //TODO CHANGE!	
		public static const MO_LOAD_URL : String = "/media/static/mo/locale/";
        public static const MO_PACKAGE_NAME : String = "messages";
        
        // ========================================================================================
        
	    protected static var _instance : L;
		public static function get instance() : L {
			if (!_instance) {
				_instance = new L();
			}
			return _instance;
		}
		
		public static function get i() : L
		{
			return instance;
		}
        
        // ========================================================================================
        
		protected var gettext : GetText;
		
		// ========================================================================================
		
		public function L()
		{
			super();
			if (L._instance) {
				throw new Error("LanguageProxy is a singleton!")
			}
			L._instance = this;
			this.gettext = GetText.getInstance();
            this.gettext.addEventListener(Event.COMPLETE, this.handleEvent);
            this.gettext.addEventListener("ioError",  this.handleError);
            this.gettext.addEventListener("error",    this.handleError);
		}
		
        // ========================================================================================
        
        public function loadLanguage(lang:String) : void
        {
            var parts:Array = FlexGlobals.topLevelApplication.url.split('/');
            var host:String = parts[0]+'//'+parts[2];
            this.gettext.translation(MO_PACKAGE_NAME, host+MO_LOAD_URL, lang);
            this.gettext.install();
        }
        
        protected function handleEvent(event:Event) : void
        {
        	this.future.data = event;
        	this.dispatchEvent(new Event("loaded"));
        }

        protected function handleError(event:Event) : void
        {
            trace(event);
        }
        
        // ========================================================================================
        [Bindable(event="loaded")]
        public function _(key:String) : String
        {
        	return GetText.translate(key);
        }
        

	}
}

