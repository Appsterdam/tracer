/*
 
 */

//These constants are defined in iTunesConnect, and will function as long
//  as this sample is built/run with the existing bundle identifier
//  (com.falconcreekstudio.The-Race-App).  If you want to experiment with this sample and
//  iTunesConnect, you'll need to define you're own bundle ID and iTunes
//  Connect configurations.  This sample uses reverse DNS for Leaderboards
//  and Achievement IDs, but this is not a requirement.  Any string that
//  iTunes Connect will accept will work fine.

//Leaderboard Category IDs
#define kLeaderboardIDTracksCompleted @"com.raceapp.TracksCompleted"
#define kLeaderboardIDTracksLaid @"com.raceapp.TracksLaid"
#define kLeaderboardIDBestTrackTimes @"com.raceapp.BestTrackTimes"


//Achievement IDs
#define kAchievementFirstTrackCompleted @"com.raceapp.FirstTrackCompleted"
#define kAchievementFirstTrackLaid @"com.raceapp.FirstTrackLaid"
#define kAchievementTenTracksCompleted @"com.raceapp.TenTracksCompleted"
#define kAchievementTenTracksLaid @"com.raceapp.TenTracksLaid"

//Notifications for GameCenterManager
#define kDidCreateTrackNotifcation @"didCreateTrackNotification"
