//
//  Constants.h
//  LATAM
//
//  Created by Ankush jain on 4/4/14.
//  Copyright (c) 2014 TCS. All rights reserved.
//


typedef enum requestPriority{
    Low = 0,
    Medium,
    High,
    Urgent
}Priority;

typedef enum reportType{
    CUS = 0,
    IV,
    GADReport,
    Image
}TypeRep;

enum errorTag {
    kAuthenticationFailed = 0,
    kReachabilityFailed,
    kDifferentUser,
    kInvalidPassword,
    kTimeOut,
    kAccessForbidden
};

enum ServiceTags {
    kFLIGHTROASTER = 0,
    kFLIGHTREPORTBYVERSION,
    kCREATEFLIGHT,
    kCREATEFLIGHTCOMPLT,
    kCHECKSTATUS,
    kCUSREPORT,
    kMANUALLIST,
    kMANUALFLIGHT,
    
    kGADREPORT,
};

typedef enum {
    LANG_ENGLISH = 1,
    LANG_SPANISH,
    LANG_PORTUGUESE
    
} LanguageSelected;

typedef enum {
    CREATEFLIGHT=0,
    CHECKSTATUS
    
} callType;

typedef enum manulFlight {
    notManualFlight=0,
    manuFlightAdded,
    manuFlightSynched,
    manuFlightErrored
} manualFlightStatus;

typedef enum DropDownType {
    NormalDropDown,
    DateDropDown,
    OtherDropDown,
    AlertDropDown,
    CameraDropDown,
    CameraDropDownImage
} dropDown;

typedef enum dateFormatterTypes {
    DATE_FORMAT_HH_mm,
    DATE_FORMAT_EEE_DD_MMM,
    DATE_FORMAT_dd_MM_yyyy_HH_mm,
    DATE_FORMAT_EEE_DD,
    DATE_FORMAT_yyyy_MM_dd_HH_mm_ss,
    DATE_FORMAT_dd,
    DATE_FORMAT_EEEE,
    DATE_FORMAT_EEEE_MMMM_dd,
    DATE_FORMAT_EEEE_dd_MMMM,
    DATE_FORMAT_EEE,
    DATE_FORMAT_DD_MMM,
    DATE_FORMAT_MMMM_yyyy,
    DATE_FORMAT_dd_MMM_yyyy,
    DATE_FORMAT_dd_MMM_HH_mm,
    DATE_FORMAT_dd_MM_yyyy_HH_mm_ss,
    DATE_FORMAT_dd_MM_yyyy,
    DATE_FORMAT_dd_MMMM_YYYY,
    DATE_FORMAT_dd_mm_yyyy_new
    
    
} DATE_FORMAT_TYPE;

typedef enum type {
    selectedLeft = 0,
    selectedRight,
    selectedMiddle,
    unselectedLeft,
    unselectedRight,
    unselectedMiddle
} TYPE;

typedef enum flightAddMode {
    Add = 0,
    Modify,
    Delete
} editMode;

typedef enum filterMode {
    no_Filter = 0,
    normalSearch_Filter,
    category_Filter,
    ffp_Filter,
    vip_Filter,
    spml_Filter,
    cnx_Filter,
    ap_Filter,
    spnd_Filter
} FilterType;

typedef enum seatState {
    Empty = 0,
    Occupied,
    Highlighted
} seatstatus;

typedef enum status {
    draft = 1,
    inqueue,
    sent,
    received,
    eror,
    ok,
    ea,
    ee,
    wf
} STATUS;

#define SALT_HASH @"FvTivqTqZXsgLLx1v3P8TGRyVHaSOB1pvfm02wvGadj7RLHV8GrfxaZ84oGA8RsKdNRpxdAojXYg9iAj"

#define NBLAN       @"NBLAN"
#define WBLAN       @"WBLAN"
#define DOMLAN      @"DMLAN"
#define NBTAM       @"NBTAM"
#define WBTAM       @"WBTAM"
#define DOMTAM      @"DMTAM"

#define TEXTFIELD_BEGIN_TAG 100

#define kCurrentLegNumber   [LTSingleton getSharedSingletonInstance].legNumber
#define kdropDownHeading [UIFont fontWithName:@"RobotoCondensed-Light" size:20]
#define kFontName_Robotica_Light @"RobotoCondensed-Light"
#define kFontSize_Heading @"25.0"
//#define kFontColor    [UIColor colorWithRed:178.0f/256.0 green:178.0f/256 blue:178.0f/256 alpha:1];
#define kFontColor [UIColor whiteColor];

// Dlog to print to the log
//#ifdef DEBUG
//#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#else
//#   define DLog(...)
//#endif
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//dateFormat

#define DATEFORMAT @"dd-MM-yyyy HH:mm:ss"
#define DATEFORMAT_Small @"dd-MM-yyyy"

#define DATEFORMAT1 @"dd-MM-yyyy"

//Constant keys
#define KEmptyString        @""

//Keychain variables
#define CuserName                                   (__bridge id)kSecAttrAccount
#define CpassWord                                   (__bridge id)kSecAttrLabel

//TextView maximum length
#define TEXTVIEWLENGTH      255
#define COMMENTVIEWLENGTH   700
#define FLIGHTNUMBERLENGTH  5

//Constant keys
#define kServerSynchStart @"StartSyching"
#define kServerSynchStop @"StopSynching"
#define kReachabilityChanged @"ReachabilityChanged"
#define kServerSychingStart @"ManualSynch"
#define KEmptyString        @""
#define kStatusChanged      @"StatusChanged"
#define kSynchronizationStart @"appdelSynch"
#define kRestartAnimation @"RestartSynchAnimation"
#define kContentByVersionUri @"contentByVersion"
#define kseatMapBCLabelFont                                    [UIFont fontWithName:@"RobotoCondensed-bold" size:30]


#define kTransitionSpeed 0.45
#define kTableViewTransitionSpeed 0.35
#define kKeyboardFrame 400
#define kTableViewScrollOffset 100

#define kNumerOfRelatedPassengers       8

#define kTablePadding 38
//url constants
#define PROTOCOL @"https://"
#define SECURE_PROTOCOL @"https://"

#define MATERIAL_ARR [[NSArray alloc] initWithObjects:@"A318",@"A319",@"A320",@"A321",@"A330",@"A340",@"A350",@"B737",@"B767",@"B777",@"B787",@"B789",@"DHC-8", nil]


//------- ENVIRONMENTS -------

// DEVELOPMENT

//
//
//#define HOSTNAME @"10.10.225.55"
//#define REACHABILITY_HOST HOSTNAME
//#define VERSION @"d"
//#define BASEURL @"http://10.10.225.55:7001/WSRestHGSAB-2.0-rest/api/"
//#define URI @"http://10.10.225.55:7001"
//#define PORT @"7001"
//#define CHECKSTATUS_URI @"checkReportStatus"
//#define MANUAL_FLIGHT @"WSRestHGSAB-1.0/manualFlights"
//#define VERSION_URI @"WSRestHGSAB-2.0-rest/api/flightReportContentsByVersion"


#define HOSTNAME @"57.228.167.42"
#define REACHABILITY_HOST HOSTNAME
#define VERSION @"d"
#define BASEURL @"http://57.228.167.42:21132/WSRestHGSAB-2.0-rest/api/"
#define URI @"http://57.228.167.42:21132"
#define PORT @"21132"
#define CHECKSTATUS_URI @"checkReportStatus"
#define MANUAL_FLIGHT @"WSRestHGSAB-1.0/manualFlights"
#define VERSION_URI @"WSRestHGSAB-2.0-rest/api/flightReportContentsByVersion"

// BETA

//#define VERSION @"b"
//#define BASEURL @"http://200.14.104.160/WSRestHGSAB-2.0-rest/api/"
//#define URI @"http://200.14.104.160"
//#define HOSTNAME @"200.14.104.160"
//#define REACHABILITY_HOST HOSTNAME
//#define PORT @"80"
//#define CHECKSTATUS_URI @"checkReportStatus"
//#define MANUAL_FLIGHT @"WSRestHGSAB-1.0/manualFlights"
//#define VERSION_URI @"WSRestHGSAB-2.0-rest/api/flightReportContentsByVersion"

// PRODUCTION

//#define VERSION @"p"
//#define BASEURL @"https://epax.lanchile.cl/WSRestHGSAB-2.0-rest/api/"
//#define URI @"https://epax.lanchile.cl"
//#define HOSTNAME @"epax.lanchile.cl"
//#define REACHABILITY_HOST HOSTNAME
//#define PORT @"443"
//#define CHECKSTATUS_URI @"checkReportStatus"
//#define MANUAL_FLIGHT @"WSRestHGSAB-1.0/manualFlights"
//#define VERSION_URI @"WSRestHGSAB-2.0-rest/api/flightReportContentsByVersion"

//----------------------------

//#endif

// BETA

//#define VERSION @"B"
//#define BASEURL @"https://epaxbeta.lanchile.cl/WSRestHGSAB-2.0-rest/api/"
//#define URI @"https://epaxbeta.lanchile.cl"
//#define HOSTNAME @"epaxbeta.lanchile.cl"
//#define REACHABILITY_HOST HOSTNAME
//#define PORT @"443"
//#define CHECKSTATUS_URI @"checkReportStatus"
//#define MANUAL_FLIGHT @"WSRestHGSAB-1.0/manualFlights"
//#define VERSION_URI @"WSRestHGSAB-2.0-rest/api/flightReportContentsByVersion"

//----------------------------

//#endif

#define MAILDUMMY @"informativoscuslatam@gmail.com"

#define MANUALS @"WSRestHGSAB-1.0/manuals"
#define ROASTER_URI @"WSRestHGSAB-1.0/userInformation"

//Keychain variables
#define CuserName                                   (__bridge id)kSecAttrAccount
#define CpassWord                                   (__bridge id)kSecAttrLabel

//Tag for switch
#define kLegExecutedTag 999
#define kSeatRowLetterTag 97
#define kSysbolForSeparator @"/"

//Tag for mandatory
#define MANDATORYTAG 19191

//Tag for CUS
#define kCusTag         2345
//placeholder attributed text for flight report
#define kDarkPlaceholder(str) [[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:.3 green:.3 blue:.3 alpha:1.0]}];

// Fonts
#define KFontName                                   @"RobotoCondensed-Light"
#define KTitleFontName                              @"RobotoCondensed-Light"
#define KLabelFont                                  @"RobotoCondensed-Light"
#define kDropDownFont                               [UIFont fontWithName:@"RobotoCondensed-Light" size:14]
#define knotesViewFont                               [UIFont fontWithName:@"RobotoCondensed-Light" size:18]

#define kCUSUserFont                                [UIFont fontWithName:@"RobotoCondensed-Light" size:16]
#define kCUSFont                                    [UIFont fontWithName:@"RobotoCondensed-Light" size:17]

#define kCUSTitleFont                                [UIFont fontWithName:@"RobotoCondensed-Light" size:14]

#define kManualFlightFontRed                          [UIColor colorWithRed:166.0/256.0f green:20.0f/256.0 blue:35.0/256.0f alpha:1.0]
#define kManualFlightFontBlue                           [UIColor colorWithRed:0.0/255.0f green:50.0f/255.0 blue:109.0/255.0f alpha:1.0]

#define KCUSFontColor1                               [UIColor colorWithRed:58.0f/256.0 green:58.0f/256 blue:58.0f/256 alpha:1]
#define KCUSFontColor                                [UIColor grayColor]

#define KRobotoFontColor                            [UIColor colorWithRed:05.0f/256.0 green:29.0f/256 blue:85.0f/256 alpha:1]
#define KRobotoFont                                [UIFont fontWithName:@"RobotoCondensed-Light" size:20]

#define KRobotoFontForHeader                       [UIFont fontWithName:@"RobotoCondensed-Light" size:26]
#define KRobotoFontColorForHeader                  [UIColor colorWithRed:05.0f/256.0 green:29.0f/256 blue:85.0f/256 alpha:1]

#define KRobotoFontForLeftLabel                      [UIFont fontWithName:@"RobotoCondensed-Light" size:21]
#define KRobotoFontColorForLeftLabel                 [UIColor colorWithRed:34.0f/256.0 green:65.0f/256 blue:108.0f/256 alpha:1]

#define KRobotoFontColorForManualflightLabel                 [UIColor colorWithRed:31.0f/256.0 green:60.0f/256 blue:104.0f/256 alpha:1]

#define KRobotoFontForRightLabel                     [UIFont fontWithName:@"RobotoCondensed-Light" size:21]
#define KRobotoFontColorForRightLabel                [UIColor colorWithRed:77.0f/256.0 green:77.0f/256.0 blue:79.0f/256.0 alpha:1]


#define KRobotoFontColorDarkBlue                    [UIColor colorWithRed:21.0f/256.0 green:42.0f/256 blue:112.0f/256 alpha:1]
#define KRobotoFontColorLightBlue                   [UIColor colorWithRed:44.0f/256.0 green:79.0f/256 blue:131.0f/256 alpha:1]
#define KRobotoFontColorGray                        [UIColor colorWithRed:77.0f/256.0 green:77.0f/256.0 blue:79.0f/256.0 alpha:1]

#define KRobotoFontSize20                                [UIFont fontWithName:@"RobotoCondensed-Light" size:20]
#define KRobotoFontSize18                                [UIFont fontWithName:@"RobotoCondensed-Light" size:18]
#define KRobotoFontSize16                                [UIFont fontWithName:@"RobotoCondensed-Light" size:16]
#define KRobotoFontSize14                                [UIFont fontWithName:@"RobotoCondensed-Light" size:14]
#define KRobotoFontSize12                                [UIFont fontWithName:@"RobotoCondensed-Light" size:12]
#define KRobotoFontSize10                                [UIFont fontWithName:@"RobotoCondensed-Light" size:10]

#define KSeparatorLineColor                            [UIColor colorWithRed:207.0f/256.0 green:208.0f/256 blue:210.0f/256 alpha:0.86];


#define kFlightReportCellTextColor [UIColor whiteColor];
#define KOkButtonTitle                              @"OK"
#define KYesButtonTitle                             @"Yes"
#define KNoButtonTitle                              @"No"
#define kreportButtonTitile     @"RobotoCondensed-Light"
#define kSectionalHeaderTextColour [UIColor whiteColor]
#define kSectionalHeaderTextSize [UIFont fontWithName:@"RobotoCondensed-Light" size:18] //[UIFont boldSystemFontOfSize:18]

#define kSeatBackgroundColor    [UIColor colorWithRed:255.0f/256.0 green:255.0f/256 blue:255.0f/256 alpha:0.7];

#define kSeatAccessoryDividerColor    [UIColor colorWithRed:204.0f/256.0 green:204.0f/256 blue:204.0f/256 alpha:.86];



#define kSeatRibbonRedColor    [UIColor colorWithRed:159.0f/256.0 green:1.0f/256 blue:15.0f/256 alpha:0.86];

#define kSeatRibbonGreenColor [UIColor colorWithRed:25.0f/256.0 green:123.0f/256 blue:18.0f/256 alpha:0.86];

#define kSeatRibbonBlueColor     [UIColor colorWithRed:38.0f/256.0 green:107.0f/256 blue:161.0f/256 alpha:0.86];

#define kSeatRibbonGrayColor    [UIColor colorWithRed:180.0f/256.0 green:192.0f/256 blue:206.0f/256 alpha:0.86];

#define kTimeFontSize 16
#define kTimeLabelWidth 45

#define KAmountLength 3
#define kDutyFreeAmountLength 7
#define KPhoneNumLength 20
#define KAddressLength 150
#define KEmailLength 60
#define kSectionalHeaderLableXPosition  42

#define kSectionalFooterWidth 578 - 52
#define kSectionalHeaderWidth 578 - 52

//#define kSectionalFooterImage @"N__001_line_.png"
#define kSectionalFooterImage @"line_dash.png"

#define KOtherFieldsLength 29

#define DOTTED_LABEL @"............................................................................................................................................................................................................................................................................................................................................."

#define TEMP_PDF @"temp.pdf"

#define IOS_OLDER_THAN_6 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] < 6.0 )
#define IOS_NEWER_OR_EQUAL_TO_6 ( [ [ [ UIDevice currentDevice ] systemVersion ] floatValue ] >= 6.0 )
#define fontStyleHelvetica @"Helvetica"
#define FILE_STATUS @"FileStatus"
#define noteTextImage @"text.png"
#define NULLSTRING @""
#define editorName @"Editor Name"
#define noteTextAnnotationType @"TextAnnotate"
#define searchKeyword @"Search"
#define addBookmarkButtonTitle @"Add bookmark"
#define mailComposeViewController @"MFMailComposeViewController"
#define EmailSUBJECT @"Document from my Ipad!"
#define EmailBODY @"I just send this File, check it out."
#define DOT @"."
#define PDF @"pdf"
#define MIMETYPE_PDF @"application/pdf"
#define PPT @"ppt"
#define PPTX @"pptx"
#define MIMETYPE_PPT @"application/vnd.ms-powerpoint"
#define MSEXCEL @"xls"
#define XLSX @"xlsx"
#define MIMETYPE_MSEXCEL @"application/vnd.ms-excel"
#define MIMETYPE_MSWORD @"application/msword"
#define DOC @"doc"
#define DOCX @"docx"
#define REFERPAGE_PLIST_FILENAME @"RefferPage.plist"
#define BOOKMARK_BUTTONTITLE @"Bookmark"
#define KEY_PAGE @"page"
#define KEY_DATE @"date"
#define TEMP_PDF @"temp.pdf"

#define SEARCH_ANIMATION_TEXT @"Searching..."
#define EmailErrorMsg_ALERT_TITLE @"No Mail Accounts"
#define EmailErrorMsg_ALERT_MSG @"Please set up a Mail account in order to send Email"

#define ALERT_CancelButtonTitle @"Ok"
#define STRING_FORMATSTRING @"%@"
#define LOG_DataWrittenToPlist @"Data written into plist."
#define LOG_DataNotWrittenToPlist @"Could not write data into plist."

#define SearchErrorMsg_ALERT_TITLE @"Alert"
#define SearchErrorMsg_ALERT_MSG @"Text is not found"
#define CELL_IDENTIFIER @"Cell"
#define DATE_FORMAT @"MM-dd-yyyy"
#define BOOKMARK_PLIST_FILENAME @"%@_bookmark.plist"

#define AnnotListErrorMsg_ALERT_TITLE @"Alert"
#define AnnotListErrorMsg_ALERT_MSG @"No Annotations Found in this Document"
#define LOG_PrintFailed @"Print failed"
#define TEMP_FILE_FOR_PRINTING @"%@/TempFileForPrinting.pdf"

#define UndoAnnotation_ALERT_TITLE @"PDF"
#define UndoAnnotation_ALERT_MSG @"No annotations to be undone"
#define FreeHandAnnotation_TYPE @"freeHandAnnotation"
#define CircleAnnotation_TYPE @"Circle"
#define RectangleAnnotation_TYPE @"Rect"
#define HighlightTextAnnotation_TYPE @"highLightAnnotation"
#define NoteTextAnnotation_TYPE @"TextAnnotate"
#define TextAnnotation_TYPE @"TextAnnotation"
#define StrikeTextAnnotation_TYPE @"FreeHandAnnotate"


#define RedoAnnotation_ALERT_TITLE @"PDF"
#define RedoAnnotation_ALERT_MSG @"No annotations to be redone"
#define SaveAnnotation_ALERT_TITLE @"Alert"
#define SaveAnnotation_ALERT_MSG @"File has been saved successfully"

#define NOTES_PLIST_OFFLINE_FILENAME @"%@_notes_offLine.plist"
#define NOTES_PLIST_ONLINE_FILENAME @"%@_notes_onLine.plist"

#define KEY_FILEPATH @"filePath"
#define KEY_TAG @"tag"
#define KEY_ANNOTATEDTEXT @"text"
#define KEY_XPOINT @"xPoint"
#define KEY_YPOINT @"yPoint"
#define KEY_FONTSIZE @"FontSize"
#define textAnnotationFontSize 20.0


#define TEXTANNOTATION_PLIST_OFFLINE_FILENAME @"%@_freeNotes_offLine.plist"
#define TEXTANNOTATION_PLIST_ONLINE_FILENAME @"%@_freeNotes_onLine.plist"

#define KEY_TEXTVIEWWIDTH @"textViewWidth"
#define KEY_TEXTVIEWHEIGHT @"textViewHeight"

#define FreeHandAnnotation_PLIST_OFFLINE_FILENAME @"%@_freeHand_offLine.plist"
#define FreeHandAnnotation_PLIST_ONLINE_FILENAME @"%@_freeHand_onLine.plist"
#define KEY_PROPERPOINTS @"properPoints"
#define KEY_MARKERCOLOR @"markerColor"
#define KEY_THICKNESS @"thickness"

#define HighlightAnnotation_PLIST_OFFLINE_FILENAME @"%@_highLight_offLine.plist"
#define HighlightAnnotation_PLIST_ONLINE_FILENAME @"%@_highLight_onLine.plist"

//#define BOOKMARK_PLIST_FILENAME @"%@_bookmark.plist"
#define BOOKMARK_PLIST_OFFLINE_FILENAME @"%@_bookmark_offLine.plist"
#define BOOKMARK_PLIST_ONLINE_FILENAME @"%@_bookmark_onLine.plist"
#define ANNOTLIST_PLIST_FILENAME @"%@_annotList.plist"
#define SORT_TEXT @"Sort"

#define ANIMATIONTEXT_ResizeForKeyboard @"ResizeForKeyboard"

#define ENABLE_USERINTERACTION @"ENABLE_USERINTERACTION"

#define LONGHAUL @"Long Haul"
#define SHORTHAUL @"Short Haul"
#define DOMESTIC @"Domestico"

#define kBE @"BE"
#define kPE @"PE"
#define kE  @"E"
#define kSE @"SE"
#define kEX @"EX"
#define kNO @"NO"

#define kES @"ES"

#define kAE @"AE"
#define kIE @"IE"

#define SET_GADDICTIONARY @"SET_GADDICTIONARY"

#define RESTNAME @"WSRestHGSAB-1.0"
#define GAD @"gad"

#pragma mark - MANUALS Constants START

#define kManualName @"Name"
#define kManualPath @"Path"
#define kManualType @"Type"
#define kManualExtension @"Extension"
#define kManualDate @"Date"
#define kManualSize @"Size"
#define kManualURI @"UriManual"
#define kManualDownloadStatus @"DownloadStatus"
#define kManualStatusMessage @"StatusMessage"
#define kManualLastSyncDate @"ManualSyncDate"
#define LATAM_MANUALS_DIR_NAME @"LATAM_MANUALS_DIR"
#define LATAM_MANUALS_BOOKMARKS_DIR_NAME @"LATAM_MANUALS_BOOKMARKS_DIR"
#define DOWNLOAD_STATUS_SUCCESS @"success"
#define DOWNLOAD_STATUS_FAIL @"fail"
#define DOWNLOAD_STATUS_STARTED @"started"
#define DOWNLOAD_STATUS_MESSAGE @"Still downloading file"
#define DOWNLOAD_MANUAL_NOTIFICATION @"LTPostNotifictaionDownloadManual"
#define UPDATE_MANUALS @"update manuals"
#define NETWORK_REACHABILITY_STATUS @"Not reachable Network"
#define START_DOWNLOAD @"start downloading"
#define MANUALS_SYNC_NOTIFICATION @"LTPostNotificationManualsSync"
#define REFRESH_FLIGHTLIST @"REFRESH_FILGHTLIST"
#define LAST_SYNCH_DATE @"LastSynchDateFOrManual"

#pragma mark - MANUALS Constants END

#define NAVIGATIONBAR_COLOR [UIColor colorWithRed:(float)243/255.0f green:(float)243/255.0f blue:(float)243/255.0f alpha:1.0f]

#define LEG_COLOR [UIColor colorWithRed:(float)247/255.0f green:(float)49/255.0f blue:(float)69/255.0f alpha:1.0f]

#define kLegOriginFontSize 18
#define kLegOriginYoffset 2
#define kLegTimeYoffset 55
#define kLegDateYoffset 73

#define kButtonWidth 240
#define kStatusIconWidth 24

#define NOTIFICATION_FLIGHTDELETE @"NOTIFICATION_FLIGHTDELETE"

#define ISiOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 )
//Added by Humera
//HeadingLabel
#define kxposition_NB_LAN_General 20
#define kyposition_NB_LAN_General 5
#define kwidth_headingLabel_NB_LAN_General 300
#define kheight_headingLabel_NB_LAN_General 30

#define kseatMapLabelFont                                    [UIFont fontWithName:@"RobotoCondensed-Light" size:14]

//seatmap populating tabel view labels
#define kseatMapLabelBusinessClassColor [UIColor whiteColor];
#define isSummaryClicked @"ISSUMMARYCLICKED"

#define kseatMapLabelBusinessClassFont                                    [UIFont fontWithName:@"RobotoCondensed-Light" size:18]

//#endif
