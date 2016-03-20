//
//  ViewController.m
//  BoogioDiagnosticApp
//
//  Created by Nate on 10/21/14.
//  Copyright (c) 2014 Reflx Labs. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "IOSCSVFileWriter.h"

@interface ViewController ()

@end

@implementation ViewController {

    //-----------------------------------------------------------------------------------
    // Members
    //-----------------------------------------------------------------------------------
    //-----------------------------------------------------------------------------------
    
    //Manager interface to Boogio hardware
    BoogioPeripheralNetworkManager *peripheralNetwork;
    
    
    //This view
    IBOutlet UIScrollView *scrollView;
    
    //Outlets
    IBOutlet UIActivityIndicatorView *leftShoeConnectionActivityIndicator;
    IBOutlet UIActivityIndicatorView *rightShoeConnectionActivityIndicator;
    
    IBOutlet UILabel *leftPeripheralNameLabel;
    IBOutlet UILabel *rightPeripheralNameLabel;
    
    IBOutlet UILabel *leftConnectionStatusLabel;
    IBOutlet UILabel *rightConnectionStatusLabel;
    
    //Force UI Elements
    IBOutlet UILabel *leftFSR0ValueLabel;
    IBOutlet UILabel *leftFSR1ValueLabel;
    IBOutlet UILabel *leftFSR2ValueLabel;
    IBOutlet UILabel *leftFSR3ValueLabel;
    
    IBOutlet UILabel *rightFSR0ValueLabel;
    IBOutlet UILabel *rightFSR1ValueLabel;
    IBOutlet UILabel *rightFSR2ValueLabel;
    IBOutlet UILabel *rightFSR3ValueLabel;
    
    IBOutlet UISwitch *subscribeToFSRNotificationsSwitch;

    //Acceleration UI Elements
    IBOutlet UILabel *leftAccelerationXValueLabel;
    IBOutlet UILabel *leftAccelerationYValueLabel;
    IBOutlet UILabel *leftAccelerationZValueLabel;
    
    IBOutlet UILabel *rightAccelerationXValueLabel;
    IBOutlet UILabel *rightAccelerationYValueLabel;
    IBOutlet UILabel *rightAccelerationZValueLabel;
    
    IBOutlet UISwitch *subscribeToAccelerationNotificationsSwitch;
    
    //Rotation UI Elements
    IBOutlet UILabel *leftRotationXValueLabel;
    IBOutlet UILabel *leftRotationYValueLabel;
    IBOutlet UILabel *leftRotationZValueLabel;

    IBOutlet UILabel *rightRotationXValueLabel;
    IBOutlet UILabel *rightRotationYValueLabel;
    IBOutlet UILabel *rightRotationZValueLabel;

    IBOutlet UISwitch *subscribeToRotationNotificationsSwitch;

    //Direction UI Elements
    IBOutlet UILabel *leftDirectionXValueLabel;
    IBOutlet UILabel *leftDirectionYValueLabel;
    IBOutlet UILabel *leftDirectionZValueLabel;
    
    IBOutlet UILabel *rightDirectionXValueLabel;
    IBOutlet UILabel *rightDirectionYValueLabel;
    IBOutlet UILabel *rightDirectionZValueLabel;
    
    IBOutlet UISwitch *subscribeToDirectionNotificationsSwitch;
    
    
    //Battery UI Elements
    IBOutlet UIButton *readBatteryChargePercentageButton;

    IBOutlet UILabel *leftBatteryChargePercentageValueLabel;
    IBOutlet UILabel *rightBatteryChargePercentageValueLabel;
    
    
    //Received Signal Strength UI Elements
    IBOutlet UILabel *leftRSSIValueLabel;
    IBOutlet UILabel *rightRSSIValueLabel;
    
    //Manager for writing CSV Files to be sent as email attachments
    IOSCSVFileWriter *csvFileWriter;
    
    //Recording State
    BOOL recordingIsEnabled;
    
    //Recording UI Elements
    IBOutlet UISwitch *enableRecordingSwitch;
    IBOutlet UIActivityIndicatorView *recordingActivityIndicator0;
    IBOutlet UIActivityIndicatorView *recordingActivityIndicator1;
    
    //Readings to which the labels set their values
    int leftToeForceValue;
    int leftBallForceValue;
    int leftArchForceValue;
    int leftHeelForceValue;
    int leftAccelerationXValue;
    int leftAccelerationYValue;
    int leftAccelerationZValue;
    int leftRotationXValue;
    int leftRotationYValue;
    int leftRotationZValue;
    int leftDirectionXValue;
    int leftDirectionYValue;
    int leftDirectionZValue;
    
    int rightToeForceValue;
    int rightBallForceValue;
    int rightArchForceValue;
    int rightHeelForceValue;
    int rightAccelerationXValue;
    int rightAccelerationYValue;
    int rightAccelerationZValue;
    int rightRotationXValue;
    int rightRotationYValue;
    int rightRotationZValue;
    int rightDirectionXValue;
    int rightDirectionYValue;
    int rightDirectionZValue;
    
    
    
}

//-----------------------------------------------------------------------------------
// Constants
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------


#define SETTINGS_SCROLL_VIEW_WIDTH      320
#define SETTINGS_SCROLL_VIEW_HEIGHT     1400

//-----------------------------------------------------------------------------------
// ViewController Callback Methods
// Keep in mind these are not always invoked properly by the OS.
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    peripheralNetwork = [appDelegate getBoogioPeripheralNetworkReference];
    
    [self refreshLabels];
    
    csvFileWriter = [[IOSCSVFileWriter alloc]init];
    
    
    //Disable sleep
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}
-(void)viewWillLayoutSubviews {
    [super viewDidLayoutSubviews];
    scrollView.contentSize = CGSizeMake(SETTINGS_SCROLL_VIEW_WIDTH, SETTINGS_SCROLL_VIEW_HEIGHT);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [peripheralNetwork setDelegate:self];
    
    //It's necessary to manually disconnect here as an edge case after presenting the mail dialog
    [peripheralNetwork disconnectFromAllPeripherals];
    [peripheralNetwork connectToPairedPeripherals];
    
    [self refreshLabels];
    
    [csvFileWriter initializeSensorReadingsFiles];
    
    [self.navigationController.navigationBar setHidden:TRUE];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [peripheralNetwork disconnectFromAllPeripherals];
    
    [self refreshLabels];
}

//-----------------------------------------------------------------------------------
// Methods
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
- (void)refreshLabels {

    NSString *pairMessage           = @"Tap + To Pair";
    NSString *scanningMessage       = @"Scanning...";
    NSString *connectedMessage      = @"Connected";
    
    NSString *leftPeripheralUUID    = [BoogioGlobals getPersistentSettingsValueForKey:LEFT_SHOE_UUID_KEY_STRING];
    NSString *rightPeripheralUUID   = [BoogioGlobals getPersistentSettingsValueForKey:RIGHT_SHOE_UUID_KEY_STRING];
    
    NSString *leftPeripheralName    = [BoogioGlobals getPersistentSettingsValueForKey:LEFT_SHOE_NAME_KEY_STRING];
    NSString *rightPeripheralName   = [BoogioGlobals getPersistentSettingsValueForKey:RIGHT_SHOE_NAME_KEY_STRING];
    
    
    if(leftPeripheralUUID == nil) {
        [leftConnectionStatusLabel setText:pairMessage];
        [leftShoeConnectionActivityIndicator stopAnimating];
    }
    else if([[peripheralNetwork getPairedPeripheralAtLocation:LEFT_SHOE] getConnectionState] == CBPeripheralStateConnected) {
        [leftConnectionStatusLabel setText:connectedMessage];
        [leftShoeConnectionActivityIndicator stopAnimating];
    }
    else {
        [leftConnectionStatusLabel setText:scanningMessage];
        [leftShoeConnectionActivityIndicator startAnimating];
    }
    
    
    if(rightPeripheralUUID ==  nil) {
        [rightConnectionStatusLabel setText:pairMessage];
        [rightShoeConnectionActivityIndicator stopAnimating];
    }
    else if([[peripheralNetwork getPairedPeripheralAtLocation:RIGHT_SHOE] getConnectionState] == CBPeripheralStateConnected) {
        [rightConnectionStatusLabel setText:connectedMessage];
        [rightShoeConnectionActivityIndicator stopAnimating];
    }
    else {
        [rightConnectionStatusLabel setText:scanningMessage];
        [rightShoeConnectionActivityIndicator startAnimating];
    }

    [leftPeripheralNameLabel setText:leftPeripheralName];
    [rightPeripheralNameLabel setText:rightPeripheralName];
}

- (void)refreshNotificationSubscriptionStates {
    if (subscribeToFSRNotificationsSwitch.on) {
        [peripheralNetwork subscribeToBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:FORCE_TYPE];
        [peripheralNetwork subscribeToBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:FORCE_TYPE];
    }
    else{
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:FORCE_TYPE];
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:FORCE_TYPE];
    }
    
    if (subscribeToAccelerationNotificationsSwitch.on) {
        [peripheralNetwork subscribeToBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:ACCELERATION_TYPE];
        [peripheralNetwork subscribeToBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:ACCELERATION_TYPE];
    }
    else{
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:ACCELERATION_TYPE];
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:ACCELERATION_TYPE];
    }
    
    if (subscribeToRotationNotificationsSwitch.on) {
        [peripheralNetwork subscribeToBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:ROTATION_TYPE];
        [peripheralNetwork subscribeToBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:ROTATION_TYPE];
    }
    else{
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:ROTATION_TYPE];
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:ROTATION_TYPE];
    }
    
    if (subscribeToDirectionNotificationsSwitch.on) {
        [peripheralNetwork subscribeToBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:DIRECTION_TYPE];
        [peripheralNetwork subscribeToBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:DIRECTION_TYPE];
    }
    else{
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:LEFT_SHOE forNotificationsAbout:DIRECTION_TYPE];
        [peripheralNetwork unsubscribeFromBoogioPeripheralAt:RIGHT_SHOE forNotificationsAbout:DIRECTION_TYPE];
    }
}

//-----------------------------------------------------------------------------------
// UI Event Callbacks
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
- (IBAction)boogioLogoButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.boogio.com"]];
}
- (IBAction)subscribeToFSRNotificationsSwitchPressed:(id)sender {
    [self refreshNotificationSubscriptionStates];
}
- (IBAction)subscribeToAccelerationNotificationsSwitchPressed:(id)sender {
    [self refreshNotificationSubscriptionStates];
}
- (IBAction)subscribeToRotationNotificationsSwitchPressed:(id)sender {
    [self refreshNotificationSubscriptionStates];
}
- (IBAction)subscribeToDirectionNotificationsSwitchPressed:(id)sender {
    [self refreshNotificationSubscriptionStates];
}
- (IBAction)readBatteryChargePercentageButtonPressed:(id)sender {
    [peripheralNetwork readDataFromBoogioPeripheralAt:LEFT_SHOE ofDataType:BATTERY_LEVEL_TYPE];
    [peripheralNetwork readDataFromBoogioPeripheralAt:RIGHT_SHOE ofDataType:BATTERY_LEVEL_TYPE];
    
    [peripheralNetwork readDataFromBoogioPeripheralAt:LEFT_SHOE ofDataType:RSSI_TYPE];
    [peripheralNetwork readDataFromBoogioPeripheralAt:RIGHT_SHOE ofDataType:RSSI_TYPE];

}
- (IBAction)enableRecordingSwitchPressed:(id)sender {
    if (enableRecordingSwitch.on) {
        [csvFileWriter initializeSensorReadingsFiles];
        recordingIsEnabled = TRUE;
        [recordingActivityIndicator0 startAnimating];
        [recordingActivityIndicator1 startAnimating];
    }
    else {
        recordingIsEnabled = FALSE;
        [recordingActivityIndicator0 stopAnimating];
        [recordingActivityIndicator1 stopAnimating];
        
    }
    
}
- (IBAction)sendSensorReadingsButtonPressed:(id)sender {
    
    
    [enableRecordingSwitch setOn:FALSE animated:YES];
    recordingIsEnabled = FALSE;
    [recordingActivityIndicator0 stopAnimating];
    [recordingActivityIndicator1 stopAnimating];
    
    NSString *documentsDirectory = [csvFileWriter getDocumentsDirectoryPath];
    
    NSString *recordingFilePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [csvFileWriter getCSVFileName]];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:@"Boogio CSV File"];
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    [csvFileWriter writeOutQueuesToFiles];
    
    NSData *recordingFile = [manager contentsAtPath:recordingFilePath];
    [picker addAttachmentData:recordingFile mimeType:@"text/csv" fileName:[csvFileWriter getCSVFileName]];
    
    
    // Fill out the email body text
    NSString *emailBody = @"Boogio CSV file attached.";
    [picker setMessageBody:emailBody isHTML:NO];
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (IBAction)clearSensorReadingsButtonPressed:(id)sender {
    [csvFileWriter initializeSensorReadingsFiles];
}
//-----------------------------------------------------------------------------------
// BoogioPeripheralNetworkManager Callback Methods
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
- (void)boogioPeripheralDidConnect:(BoogioPeripheral*)boogioPeripheral {
    [self refreshNotificationSubscriptionStates];
    [self refreshLabels];
}
- (void)boogioPeripheralDidDisconnect:(BoogioPeripheral*)boogioPeripheral {
    [self refreshLabels];
}
- (void)boogioPeripheral:(BoogioPeripheral*)boogioPeripheral
             DidSendData:(NSArray*)data
                  ofType:(BOOGIO_DATA_TYPE)sensorDataType {

    float batteryCharge;
    int signalStrength = 0;
    
    
    switch (sensorDataType) {
        case FORCE_TYPE:
            switch ([boogioPeripheral getLocation]) {
                case LEFT_SHOE:
                    leftToeForceValue  = [data[DATA_INDEX_FORCE_TOE] intValue];
                    leftBallForceValue = [data[DATA_INDEX_FORCE_BALL] intValue];
                    leftArchForceValue = [data[DATA_INDEX_FORCE_ARCH] intValue];
                    leftHeelForceValue = [data[DATA_INDEX_FORCE_HEEL] intValue];

                    [leftFSR0ValueLabel setText:[data[DATA_INDEX_FORCE_TOE] stringValue]];
                    [leftFSR1ValueLabel setText:[data[DATA_INDEX_FORCE_BALL] stringValue]];
                    [leftFSR2ValueLabel setText:[data[DATA_INDEX_FORCE_ARCH] stringValue]];
                    [leftFSR3ValueLabel setText:[data[DATA_INDEX_FORCE_HEEL] stringValue]];
                    

                    break;
                case RIGHT_SHOE:
                    rightToeForceValue  = [data[DATA_INDEX_FORCE_TOE] intValue];
                    rightBallForceValue = [data[DATA_INDEX_FORCE_BALL] intValue];
                    rightArchForceValue = [data[DATA_INDEX_FORCE_ARCH] intValue];
                    rightHeelForceValue = [data[DATA_INDEX_FORCE_HEEL] intValue];
                    
                    [rightFSR0ValueLabel setText:[data[DATA_INDEX_FORCE_TOE] stringValue]];
                    [rightFSR1ValueLabel setText:[data[DATA_INDEX_FORCE_BALL] stringValue]];
                    [rightFSR2ValueLabel setText:[data[DATA_INDEX_FORCE_ARCH] stringValue]];
                    [rightFSR3ValueLabel setText:[data[DATA_INDEX_FORCE_HEEL] stringValue]];

                    break;
                default:
                    break;
            }
            break;
        case ACCELERATION_TYPE:
            switch ([boogioPeripheral getLocation]) {
                case LEFT_SHOE:
                    leftAccelerationXValue = [data[DATA_INDEX_ACCELERATION_X] intValue];
                    leftAccelerationYValue = [data[DATA_INDEX_ACCELERATION_Y] intValue];
                    leftAccelerationZValue = [data[DATA_INDEX_ACCELERATION_Z] intValue];
                    
                    [leftAccelerationXValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ACCELERATION_X] intValue]]];
                    [leftAccelerationYValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ACCELERATION_Y] intValue]]];
                    [leftAccelerationZValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ACCELERATION_Z] intValue]]];
                    break;
                case RIGHT_SHOE:
                    rightAccelerationXValue = [data[DATA_INDEX_ACCELERATION_X] intValue];
                    rightAccelerationYValue = [data[DATA_INDEX_ACCELERATION_Y] intValue];
                    rightAccelerationZValue = [data[DATA_INDEX_ACCELERATION_Z] intValue];
                    
                    [rightAccelerationXValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ACCELERATION_X] intValue]]];
                    [rightAccelerationYValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ACCELERATION_Y] intValue]]];
                    [rightAccelerationZValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ACCELERATION_Z] intValue]]];
                    break;
                default:
                    break;
            }
            break;
        case ROTATION_TYPE:
            switch ([boogioPeripheral getLocation]) {
                case LEFT_SHOE:
                    leftRotationXValue = [data[DATA_INDEX_ROTATION_X] intValue];
                    leftRotationYValue = [data[DATA_INDEX_ROTATION_Y] intValue];
                    leftRotationZValue = [data[DATA_INDEX_ROTATION_Z] intValue];
                    
                    [leftRotationXValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ROTATION_X] intValue]]];
                    [leftRotationYValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ROTATION_Y] intValue]]];
                    [leftRotationZValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ROTATION_Z] intValue]]];
                    break;
                case RIGHT_SHOE:
                    rightRotationXValue = [data[DATA_INDEX_ROTATION_X] intValue];
                    rightRotationYValue = [data[DATA_INDEX_ROTATION_Y] intValue];
                    rightRotationZValue = [data[DATA_INDEX_ROTATION_Z] intValue];
                    
                    [rightRotationXValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ROTATION_X] intValue]]];
                    [rightRotationYValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ROTATION_Y] intValue]]];
                    [rightRotationZValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_ROTATION_Z] intValue]]];
                    break;
                default:
                    break;
            }
            break;
        case DIRECTION_TYPE:
            switch ([boogioPeripheral getLocation]) {
                case LEFT_SHOE:
                    leftDirectionXValue = [data[DATA_INDEX_DIRECTION_X] intValue];
                    leftDirectionYValue = [data[DATA_INDEX_DIRECTION_Y] intValue];
                    leftDirectionZValue = [data[DATA_INDEX_DIRECTION_Z] intValue];
                    
                    [leftDirectionXValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_DIRECTION_X] intValue]]];
                    [leftDirectionYValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_DIRECTION_Y] intValue]]];
                    [leftDirectionZValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_DIRECTION_Z] intValue]]];
                    break;
                case RIGHT_SHOE:
                    rightDirectionXValue = [data[DATA_INDEX_DIRECTION_X] intValue];
                    rightDirectionYValue = [data[DATA_INDEX_DIRECTION_Y] intValue];
                    rightDirectionZValue = [data[DATA_INDEX_DIRECTION_Z] intValue];
                    
                    [rightDirectionXValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_DIRECTION_X] intValue]]];
                    [rightDirectionYValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_DIRECTION_Y] intValue]]];
                    [rightDirectionZValueLabel setText:[NSString stringWithFormat:@"%d",[data[DATA_INDEX_DIRECTION_Z] intValue]]];
                    break;
                default:
                    break;
            }
            break;
        case BATTERY_LEVEL_TYPE:
            batteryCharge = [data[DATA_INDEX_BATTERY_CHARGE] floatValue];
            switch ([boogioPeripheral getLocation]) {
                case LEFT_SHOE:
                    [leftBatteryChargePercentageValueLabel setText:[NSString stringWithFormat:@"%2.0f %%", batteryCharge]];
                    break;
                case RIGHT_SHOE:
                    [rightBatteryChargePercentageValueLabel setText:[NSString stringWithFormat:@"%2.0f %%", batteryCharge]];
                    break;
                default:
                    break;
            }
            break;
        case RSSI_TYPE:
            switch ([boogioPeripheral getLocation]) {
                case LEFT_SHOE:
                    signalStrength = 100 + [data[DATA_INDEX_RSSI] intValue];
                    [leftRSSIValueLabel setText:[NSString stringWithFormat:@"%d %%", signalStrength]];
                    break;
                case RIGHT_SHOE:
                    signalStrength = 100 + [data[DATA_INDEX_RSSI] intValue];
                    [rightRSSIValueLabel setText:[NSString stringWithFormat:@"%d %%", signalStrength]];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    if(recordingIsEnabled) {
        NSString *dateFormat = @"yyyy/MM/dd HH:mm:ss.SSS";
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:dateFormat];
        NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
        
        
        dateString = [NSString stringWithFormat:@"%@", dateString];
        
        NSString *leftForceDataString          = [NSString stringWithFormat:@"%d, %d, %d, %d", leftToeForceValue,       leftBallForceValue,      leftArchForceValue,       leftHeelForceValue];
        NSString *leftAccelerationDataString   = [NSString stringWithFormat:@"%d, %d, %d",     leftAccelerationXValue,  leftAccelerationYValue,  leftAccelerationZValue];
        NSString *leftRotationDataString       = [NSString stringWithFormat:@"%d, %d, %d",     leftRotationXValue,      leftRotationYValue,      leftRotationZValue];
        NSString *leftDirectionDataString      = [NSString stringWithFormat:@"%d, %d, %d",     leftDirectionXValue,     leftDirectionYValue,     leftDirectionZValue];
        
        NSString *rightForceDataString         = [NSString stringWithFormat:@"%d, %d, %d, %d", rightToeForceValue,      rightBallForceValue,     rightArchForceValue,      rightHeelForceValue];
        NSString *rightAccelerationDataString  = [NSString stringWithFormat:@"%d, %d, %d",     rightAccelerationXValue, rightAccelerationYValue, rightAccelerationZValue];
        NSString *rightRotationDataString      = [NSString stringWithFormat:@"%d, %d, %d",     rightRotationXValue,     rightRotationYValue,     rightRotationZValue];
        NSString *rightDirectionDataString     = [NSString stringWithFormat:@"%d, %d, %d",     rightDirectionXValue,    rightDirectionYValue,    rightDirectionZValue];

        
        NSString *line = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@\n", dateString, leftForceDataString, leftAccelerationDataString, leftRotationDataString, leftDirectionDataString, rightForceDataString, rightAccelerationDataString, rightRotationDataString, rightDirectionDataString];
        
        [csvFileWriter appendLine:line];
    }
}

//-----------------------------------------------------------------------------------
// CSV File Attachment Mail Dialog Callback
//-----------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            NSLog(@"Clearing Sensor File Contents");
            [csvFileWriter initializeSensorReadingsFiles];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
