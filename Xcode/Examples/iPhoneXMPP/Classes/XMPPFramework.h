//
//  This file is designed to be customized by YOU.
//  
//  As you pick and choose which parts of the framework you need for your application, add them to this header file.
//  
//  Various modules available within the framework optionally interact with each other.
//  E.g. The XMPPPing module will utilize the XMPPCapabilities module (if available) to advertise support XEP-0199.
// 
//  However, the modules can only interact if they're both added to your xcode project.
//  E.g. If XMPPCapabilities isn't a part of your xcode project, then XMPPPing shouldn't attempt to reference it.
// 
//  So how do the individual modules know if other modules are available?
//  Via this header file.
// 
//  If you #import "XMPPCapabilities.h" in this file, then _XMPP_CAPABILITIES_H will be defined for other modules.
//  And they can automatically take advantage of it.
//


//  CUSTOMIZE ME !
//  
//  THIS HEADER FILE SHOULD BE TAILORED TO MATCH YOUR APPLICATION.


#import "XMPP.h"

#ifdef HAVE_XMPP_SUBSPEC_BANDWIDTHMONITOR
#import "XMPPBandwidthMonitor.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_GOOGLESHAREDSTATUS
#import "XMPPGoogleSharedStatus.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_RECONNECT
#import "XMPPReconnect.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_ROSTER
#import "XMPPRoster.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_SYSTEMINPUTACTIVITYMONITOR
#import "XMPPSystemInputActivityMonitor.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0009
#import "XMPPJabberRPCModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0012
#import "XMPPLastActivity.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0016
#import "XMPPPrivacy.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0045
#import "XMPPMUC.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0045
#import "XMPPRoom.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0054
#import "XMPPvCardTempModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0060
#import "XMPPPubSub.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0100
#import "XMPPTransports.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0115
#import "XMPPCapabilities.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0136
#import "XMPPMessageArchiving.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0153
#import "XMPPvCardAvatarModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0184
#import "XMPPMessageDeliveryReceipts.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0191
#import "XMPPBlocking.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0198
#import "XMPPStreamManagement.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0199
#import "XMPPAutoPing.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0199
#import "XMPPPing.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0202
#import "XMPPAutoTime.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0202
#import "XMPPTime.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0224
#import "XMPPAttentionModule.h"
#endif

#ifdef HAVE_XMPP_SUBSPEC_XEP_0280
#import "XMPPMessageCarbons.h"
#endif

