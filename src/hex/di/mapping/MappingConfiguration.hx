package hex.di.mapping;

import hex.collection.Locator;
import hex.config.stateful.IStatefulConfig;
import hex.di.IDependencyInjector;
import hex.log.HexLog.getLogger;
import hex.module.IContextModule;
import hex.service.stateful.IStatefulService;
import hex.util.Stringifier;

/**
 * ...
 * @author Francis Bourre
 */
class MappingConfiguration extends Locator<String, Helper> implements IStatefulConfig
{
	public function new() 
	{
		super();
	}
	
	public function configure( injector : IDependencyInjector, module : IContextModule ) : Void
	{
		var keys = this.keys();
        for ( className in keys )
        {
			var separatorIndex 	: Int = className.indexOf( "#" );
			var classKey : String;

			if ( separatorIndex != -1 )
			{
				classKey = className.substr( separatorIndex+1 );
			}
			else
			{
				classKey = className;
			}

			var helper : Helper = this.locate( className );
			var mapped : Dynamic = helper.value;

			if ( Std.is( mapped, Class ) )
			{
				if ( helper.isSingleton )
				{
					injector.mapClassNameToSingleton( classKey, mapped, helper.mapName );
				}
				else
				{
					injector.mapClassNameToType( classKey, mapped, helper.mapName );
				}
			}
			else
			{
				if ( Std.is( mapped, IStatefulService ) )
				{
					getLogger().warn( 'IStatefulService instances are not added as listener:' + Stringifier.stringify( mapped ) );
				}

				if ( helper.injectInto )
				{
					injector.injectInto( mapped );
				}
				
				injector.mapClassNameToValue( classKey, mapped, helper.mapName );
			}
		}
	}
	
	public function addMapping( type : Class<Dynamic>, value : Dynamic, ?mapName : String = "", ?asSingleton : Bool = false, ?injectInto : Bool = false ) : Bool
	{
		return this._registerMapping( Type.getClassName( type ), new Helper( value, mapName, asSingleton, injectInto ), mapName );
	}
	
	public function addMappingWithClassName( className : String, value : Dynamic, ?mapName : String = "", ?asSingleton : Bool = false, ?injectInto : Bool = false ) : Bool
	{
		return this._registerMapping( className, new Helper( value, mapName, asSingleton, injectInto ), mapName );
	}
	
	function _registerMapping( className : String, helper : Helper, ?mapName : String = "" ) : Bool
	{
		var className : String = ( mapName != "" ? mapName + "#" : "" ) + className;
		return this.register( className, helper );
	}
}

private class Helper
{
	public var value		: Dynamic;
	public var mapName		: String;
	public var isSingleton	: Bool;
	public var injectInto	: Bool;

	public function new( value : Dynamic, mapName : String, ?isSingleton : Bool, injectInto : Bool )
	{
		this.value 			= value;
		this.mapName 		= mapName;
		this.isSingleton 	= isSingleton;
		this.injectInto 	= injectInto;
	}
	
	public function toString() : String
	{
		return 'Helper( value:$value, mapName:$mapName, isSingleton:$isSingleton, injectInto:$injectInto )';
	}
}