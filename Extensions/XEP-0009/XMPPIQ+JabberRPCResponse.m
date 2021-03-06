//
//  XMPPIQ+JabberRPCResponse.m
//  XEP-0009
//
//  Created by Eric Chamberlain on 5/25/10.
//

#import "XMPPIQ+JabberRPCResponse.h"
#import "XMPPJabberRPCModule.h"
#import "XMPPLogging.h"
#import "NSData+XMPP.h"
#import "NSXMLElement+XMPP.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
#if DEBUG
  static const int xmppLogLevel = XMPP_LOG_LEVEL_VERBOSE;
#else
  static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@implementation XMPPIQ (JabberRPCResponse)

-(NSXMLElement *)methodResponseElement {
	NSXMLElement *query = [self elementForName:@"query" xmlns:@"jabber:iq:rpc"];
	return [query elementForName:@"methodResponse"];
}


-(NSXMLElement *)methodCallElement {
	NSXMLElement *query = [self elementForName:@"query" xmlns:@"jabber:iq:rpc"];
	return [query elementForName:@"methodCall"];
}

-(id)paramsFromCallElement {

    NSXMLElement *methodCall = [self methodCallElement];
    NSXMLElement *params = (NSXMLElement *)[methodCall childAtIndex:1];
    id call = [self objectFromElement: params];
    return call;
}

-(id)paramsFromResponseElement {
    NSXMLElement *methodResponse = [self methodResponseElement];
    id response = [self objectFromElement:(NSXMLElement *)[methodResponse childAtIndex:0]];
    return response;
}



-(NSString *)methodName {
    if ([self isMethodCall]) {
        NSXMLElement* methodCall = [self methodCallElement];
        return [[methodCall elementForName:@"methodName"] stringValue];
    } else {
        return nil;
    }
}




// is this a Jabber RPC method response
-(BOOL)isMethodResponse {
	/*
	<methodResponse>
	 <params>
		<param>
			<value><string>South Dakota</string></value>
		</param>
	 </params>
	</methodResponse>
	*/
	NSXMLElement *methodResponse = [self methodResponseElement];
	return methodResponse != nil;
}

// is this a Jabber RPC method request
- (BOOL)isMethodCall {
    //	<iq to="fullJID" type="set" id="elementID">
   	//		<query xmlns='jabber:iq:rpc'>
   	//			<methodCall>
   	//				<methodName>method</methodName>
   	//				<params>
   	//					<param>
   	//						<value><string>example</string></value>
   	//					</param>
   	//					...
   	//				</params>
   	//			</methodCall>
   	//		</query>
   	//	</iq>
    NSXMLElement *methodCall = [self methodCallElement];
    return methodCall != nil;
}


-(BOOL)isFault {
	/*
	<methodResponse>
	 <fault>
		<value>
			<struct>
				<member>
					<name>faultCode</name>
					<value><int>4</int></value>
				</member>
				<member>
					<name>faultString</name>
					<value><string>Too many parameters.</string></value>
				</member>
			</struct>
		</value>
	 </fault>
	</methodResponse>
	*/
	NSXMLElement *methodResponse = [self methodResponseElement];
	
	return [methodResponse elementForName:@"fault"] != nil;
}

-(BOOL)isJabberRPC {
	/*
	 <query xmlns="jabber:iq:rpc">
		...
	 </query>
	*/
	NSXMLElement *rpcQuery = [self elementForName:@"query" xmlns:@"jabber:iq:rpc"];
	return rpcQuery != nil;
}

-(id)methodResponse:(NSError **)error {
	id response = nil;
	
	/*
	<methodResponse>
		<params>
			<param>
				<value><string>South Dakota</string></value>
			</param>
		</params>
	</methodResponse>
	*/
	
	// or
	
	/*
	<methodResponse>
		<fault>
			<value>
				<struct>
					<member>
						<name>faultCode</name>
						<value><int>4</int></value>
					</member>
					<member>
						<name>faultString</name>
						<value><string>Too many parameters.</string></value>
					</member>
				</struct>
			</value>
		</fault>
	</methodResponse>
	*/
	NSXMLElement *methodResponse = [self methodResponseElement];
	
	// parse the methodResponse
	
	response = [self objectFromElement:(NSXMLElement *)[methodResponse childAtIndex:0]];
	
	if ([self isFault]) {
		// we should produce an error
		// response should be a dict
		if (error) {
			*error = [NSError errorWithDomain:XMPPJabberRPCErrorDomain 
										 code:[[response objectForKey:@"faultCode"] intValue] 
									 userInfo:(NSDictionary *)response];
		}
		response = nil;
	} else {
		if (error) {
			*error = nil;
		}
	}

	return response;
}

-(id)objectFromElement:(NSXMLElement *)param {
	NSString *element = [param name];
	
	if ([element isEqualToString:@"params"] ||
		[element isEqualToString:@"param"] ||
		[element isEqualToString:@"fault"] ||
		[element isEqualToString:@"value"]) {
		
		NSXMLElement *firstChild = (NSXMLElement *)[param childAtIndex:0];
		if (firstChild) {
			return [self objectFromElement:firstChild];
		} else {
			// no child element, treat it like a string
			return [self parseString:[param stringValue]];
		}
	} else if ([element isEqualToString:@"string"] ||
			   [element isEqualToString:@"name"]) {
		return [self parseString:[param stringValue]];
	} else if ([element isEqualToString:@"member"]) {
		return [self parseMember:param];
	} else if ([element isEqualToString:@"array"]) {
		return [self parseArray:param];
	} else if ([element isEqualToString:@"struct"]) {
		return [self parseStruct:param];
	} else if ([element isEqualToString:@"int"]) {
		return [self parseInteger:[param stringValue]];
	} else if ([element isEqualToString:@"double"]) {
		return [self parseDouble:[param stringValue]];
	} else if ([element isEqualToString:@"boolean"]) {
		return [self parseBoolean:[param stringValue]];
	} else if ([element isEqualToString:@"dateTime.iso8601"]) {
		return [self parseDate:[param stringValue]];
	} else if ([element isEqualToString:@"base64"]) {
		return [self parseData:[param stringValue]];
	} else {
		// bad element
		XMPPLogWarn(@"%@: %@ - bad element: %@, param: %@", THIS_FILE, THIS_METHOD, element, [param stringValue]);
	}
	return nil;
}				
	
				
#pragma mark -
				
-(NSArray *)parseArray:(NSXMLElement *)arrayElement {
	/*
	 <array>
		<data>
			<value><i4>12</i4></value>
			<value><string>Egypt</string></value>
			<value><boolean>0</boolean></value>
			<value><i4>-31</i4></value>
		</data>
	 </array>
	 */
	NSXMLElement *data = (NSXMLElement *)[arrayElement childAtIndex:0];
	NSArray *children = [data children];
	
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[children count]];
	
	for (NSXMLElement *child in children) {
		[array addObject:[self objectFromElement:child]];
	}
	
	return array;
}

-(NSDictionary *)parseStruct:(NSXMLElement *)structElement {
	/*
	<struct>
	 <member>
		<name>lowerBound</name>
		<value><i4>18</i4></value>
	 </member>
	 <member>
		<name>upperBound</name>
		<value><i4>139</i4></value>
	 </member>
	</struct>
	*/
	NSArray *children = [structElement children];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[children count]];
	
	for (NSXMLElement *child in children) {
		[dict addEntriesFromDictionary:[self parseMember:child]];
	}
	
	return dict;
}

-(NSDictionary *)parseMember:(NSXMLElement *)memberElement {
	NSString *key = [self objectFromElement:[memberElement elementForName:@"name"]];
	id value = [self objectFromElement:[memberElement elementForName:@"value"]];
	
	return @{key : value};
}
	
#pragma mark -

- (NSDate *)parseDateString: (NSString *)dateString withFormat: (NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat: format];
    
    NSDate *result = [dateFormatter dateFromString: dateString];
    
    return result;
}

#pragma mark -

- (NSNumber *)parseInteger: (NSString *)value {
    return @([value integerValue]);
}

- (NSNumber *)parseDouble: (NSString *)value {
    return @([value doubleValue]);
}

- (NSNumber *)parseBoolean: (NSString *)value {
    if ([value isEqualToString: @"1"]) {
        return @YES;
    }
    
    return @NO;
}

- (NSString *)parseString: (NSString *)value {
    return [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDate *)parseDate: (NSString *)value {
    NSDate *result = nil;
    
    result = [self parseDateString: value withFormat: @"yyyyMMdd'T'HH:mm:ss"];
    
    if (!result) {
        result = [self parseDateString: value withFormat: @"yyyy'-'MM'-'dd'T'HH:mm:ss"];
    }
    
    return result;
}

- (NSData *)parseData: (NSString *)value {
	// Convert the base 64 encoded data into a string
	NSData *base64Data = [value dataUsingEncoding:NSASCIIStringEncoding];
	NSData *decodedData = [base64Data xmpp_base64Decoded];
	
    return decodedData;
}

	
@end
