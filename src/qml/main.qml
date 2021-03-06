import QtQuick 2.4
import Material 0.3
import Material.ListItems 0.1 as ListItem
import QtMultimedia 5.5
import Qt.labs.folderlistmodel 2.1
import "../js/musicId.js" as Global
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.0
import QtQuick.LocalStorage 2.0

ApplicationWindow {

    function getMusic(){
        //musicFolder.initialMusicScan = "Do this";
        //console.log(musicFolder.initialMusicScan);

    }

    Timer {
        id:initScan
        interval:2000; running: false; repeat: false
        onTriggered: {
            //console.log(JSON.stringify(albumModel.getSingleAlbum(1)));
            //musicFolder.initialMusicScan = "Do this";
            //console.log(musicFolder.initialMusicScan);
        }
    }


    Timer {
        id: setSeekTimer
        interval: 500; running: false; repeat: false
        onTriggered: {
            seeker.maximumValue = parseInt(playMusic.duration)
            if(playMusic.metaData.albumTitle){
                var artist = playMusic.metaData.albumTitle
            }else{
                var artist = 'Unknown Album'
            }
            if(playMusic.metaData.title){
                var title = playMusic.metaData.title
            }else{
                folderModel.folder = Global.currentFolder
                var title = folderModel.get(Global.songId, 'fileName')
            }


        }
    }
    Timer {
        id: durationTimer
        interval: 100; running: false; repeat: true
        onTriggered: {
            if (playMusic.playbackState == 1 && !seeker.pressed){
            var curtime = playMusic.position
            seeker.value = curtime
            }

        }
    }

    Timer {
        id: changeView
        interval: 100; running: false; repeat: false
        onTriggered: {

                example.source = Qt.resolvedUrl("%1Demo.qml").arg(demo.selectedComponent.replace(" ", ""))

        }
    }
    Timer {
        id: myTimer
             interval: 200; running: false; repeat: false
             onTriggered: {

                 if(playMusic.metaData.albumTitle){
                     var artist = playMusic.metaData.albumTitle
                 }else{
                     var artist = 'Unknown Album'
                 }
                     if(playMusic.metaData.title){
                         var title = playMusic.metaData.title
                     }else{
                         folderModel.folder = Global.currentFolder
                         var title = folderModel.get(Global.songId, 'fileName')
                     }
                     musicFolder.notify = "\"" + artist + "\" \"" + title + "\""
                 }

    }

    Timer {
        id: musicWithFolder
            interval: 100; running: false; repeat: false
            onTriggered: {
                Qt.resolvedUrl("AllMusicDemo.qml")
                selectedComponent = "All Music"
            }
    }

    Timer {
        id: delayedPlay
        interval: 100; running: false; repeat: false
        onTriggered: {
            folderModel.folder = 'file://' + loadedFileFolder
            albumFolder.folder = 'file://' + loadedFileFolder
            playMusic.play()

        }

    }

    Timer {
        id: nextTimer
             interval: 200; running: false; repeat: false
             onTriggered: {
                 if(playMusic.source){
                     folderModel.folder = Global.currentFolder

                     if(Global.songId + 1 == folderModel.count){

                         var folder = folderModel.folder
                         folderModel.folder = Global.currentFolder
                         var currentSong = playMusic.source
                         var nextFile = Global.currentFolder + '/' + folderModel.get(0, 'fileName')
                         playMusic.source = nextFile
                         playMusic.play()
                         Global.songId = 1;

                     }else{
                         var folder = folderModel.folder
                         folderModel.folder = Global.currentFolder
                         var currentSong = playMusic.source
                         var nextFile = Global.currentFolder + '/' + folderModel.get(Global.songId + 1, 'fileName')
                         playMusic.source = nextFile
                         playMusic.play()
                         Global.songId++;
                     }
                 }
         }
    }


    Audio {
        id: playMusic

        onStatusChanged: {
            if (status == MediaPlayer.EndOfMedia) {
                getNextTrack()
            }

        }
        onSourceChanged: {
            if(Global.prevTrack){

            }else{
                Global.playedSongs.push(Global.songId)
            }
            Global.prevTrack = false
            myTimer.start()
            setSeekTimer.start()
            durationTimer.start()
            playButton1.iconName = 'av/pause'
        }
        Component.onCompleted: {
            if(filePathName){
                playMusic.source = 'file://' + filePathName
                delayedPlay.start()
            }
        }


    }

    FolderListModel {
        id: folderModel
        folder: {
            return "file://" + homeDirectory
        }
        nameFilters: [ "*.mp3", "*.wav" ]
        showDotAndDotDot: false
        showFiles: true
    }

    FolderListModel {
        id: streamFolder
        folder: "file://" + streamDirectory
        nameFilters: [ "*.mp3", "*.wav", "*.ogg", "*.m3u", "*.pls", !"streams" ]
        showDotAndDotDot: false
        showFiles: true
    }

    FolderListModel {
        id: albumFolder
        folder: "file://" + homeDirectory
    }

    FolderListModel {
        id: folderGetImage
        folder: "file://" + homeDirectory
        nameFilters: ["*.png", "*.jpg"]
        showFiles: true
    }

    ListView {
        id: allAlbumsModel
        model: {
                return albumModel
        }
        visible: true
    }

    ListView {
        id: allSongsModel
        model: songModel.getAllSongs()
        visible: true
    }

    ListView {
        id: artistSongsModel
        model: {

        }
        visible: true
    }

    ListView {
        id: songListModel
        model: {


        }

        visible: true
    }


    ListView {
        id: currentAlbum
    }

    id: demo
    title: "Liri Music"
    height: dp(600)
    width: dp(1200)

    Timer {
        id: resetFolders
        interval: 100; running:false; repeat:false
        onTriggered: {
            folderModel.folder = "file://" + homeDirectory
            albumFolder.folder = "file://" + homeDirectory
            streamFolder.folder = "file://" + streamDirectory


        }
    }


    // Necessary when loading the window from C++
    visible: true



    theme {
        primaryColor: Palette.colors["lightBlue"]["500"]
        primaryDarkColor: Palette.colors["lightBlue"]["700"]
        accentColor: Palette.colors["red"]["A200"]
        tabHighlightColor: "white"
    }


    property var sidebar: [
            "Albums", "Artists", "All Music", "Streams"
    ]

    property var basicComponents: [
            "Activity", "Profile", "Messages", "Discover", "Settings"
    ]

    property var compoundComponents: [
            "Artists"
    ]

    property var sections: [ sidebar, basicComponents, compoundComponents ]

    property var sectionTitles: [ "Music", "Community", "Storage"]

    property string selectedComponent: sidebar[0][0]

    function getTrack(){
        var item;

        if(Global.mode == "album"){
            item = songListModel.model[Global.songId]
            if(Global.songId >= songListModel.model.length){
                Global.songId = 0
            }else if(Global.songId < 0){
                Global.songId = 0
            }
        }else if(Global.mode == "all songs"){
            item = allSongsModel.model[Global.songId]
            if(Global.songId >= allSongsModel.model.length){
                Global.songId = 0
            }else if(Global.songId < 0){
                Global.songId = 0
            }
        }else if(Global.mode == "artist"){
            item = artistSongsModel.model[Global.songId]
            if(Global.songId >= artistSongsModel.model.length){
                Global.songId = 0
            }else if(Global.songId < 0){
                Global.songId = 0
            }
        }

        demo.title = item.title
        playMusic.source = "file://" + item.path
        playMusic.play()
        songPlaying.text = songModel.getAlbum(item.album) + ' - ' + item.title
        page.title = songModel.getAlbum(item.album)  + ' - ' + item.title
        demo.title = item.title
    }

    function getNextTrack(){
        Global.songId = Global.songId + 1
        getTrack()
    }

    function getPrevTrack(){
        Global.songId = Global.songId - 1
        getTrack()
    }

    function playTriggerAction(){
        if (playMusic.playbackState == 1){
            playMusic.pause()
            playButton1.iconName = 'av/play_arrow'
        }
        else{
            playMusic.play()
            playButton1.iconName = 'av/pause'
        }
    }

    function volumeUp(){
        var curvol = playMusic.volume
        var newVol = curvol + 0.10
        volumeControl.value = newVol
        playMusic.volume = newVol
    }

    function volumeDown(){
        var curvol = playMusic.volume
        var newVol = curvol - 0.10
        volumeControl.value = newVol
        playMusic.volume = newVol

    }

    function setLoaderSource(source){
        example.setSource(source);
    }

    initialPage: TabbedPage {


        id: page
        visible: true

        title: "Liri Music"



        Rectangle {
            height:200
            width:parent
            color: theme.primaryColor


         }

        actionBar.maxActionCount: navDrawer.enabled ? 3 : 4

        //Key Navigation
        Keys.onUpPressed: {
            volumeUp()
        }

        Keys.onDownPressed: {
            volumeDown()
        }

        Keys.onSpacePressed: {
            if(playMusic.source){
                playTriggerAction()
            }
        }


        Keys.onRightPressed: {
            if(playMusic.source){
                folderModel.folder = Global.currentFolder
                getNextTrack()
            }
        }


        Keys.onLeftPressed: {
            if(playMusic.source && Global.songId != 0){
                getPrevTrack()
            }
        }

        actions: [

            Action {
                id: settingsButton
                iconName: "action/settings"
                name: "Settings"
                onTriggered: {
                    settingsDialog.show()
                }
            }




        ]

        backAction: navDrawer.action

        NavigationDrawer {
            id: navDrawer
            visible:true

            enabled: selectedComponent == 'Activity' //page.width < dp(600)

            Flickable {
                anchors.fill: parent

                contentHeight: Math.max(content.implicitHeight, height)

                Column {
                    id: content
                    anchors.fill: parent

                    Repeater {
                        model: sections


                        delegate: Column {
                            width: parent.width


                            Repeater {
                                                    model: sections

                                                    delegate: Column {
                                                        width: parent.width

                                                        ListItem.Subheader {
                                                            text: sectionTitles[index]
                                                        }

                                                        Repeater {
                                                            model: modelData
                                                            delegate: ListItem.Subtitled{

                                                                text: modelData
                                                                selected: modelData == selectedComponent
                                                                action: IconButton {

                                                                        iconName: {
                                                                            if(modelData == 'Albums'){
                                                                            return 'av/album'
                                                                            }else if(modelData == 'Artists'){
                                                                                return 'social/person'
                                                                            }else if(modelData == 'All Music'){
                                                                                return 'av/queue_music'
                                                                            }else if(modelData == 'Streams'){
                                                                                return 'social/public'
                                                                            }else if(modelData == 'Settings'){
                                                                                return 'action/settings'
                                                                            }

                                                                        }
                                                                        anchors.topMargin: dp(20)
                                                                        height: dp(36)
                                                                        width: dp(12)
                                                                        anchors.horizontalCenter: parent.horizontalCenter

                                                                }

                                                                height: dp(42)

                                                                onClicked: {
                                                                    Global.playedSongs = []
                                                                    if(modelData == 'Profile'){
                                                                        console.log("Loading profile route.")
                                                                    }else{
                                                                        selectedComponent = modelData
                                                                    }
                                                                    folderModel.folder = "file://" + homeDirectory
                                                                    albumFolder.folder = "file://" + homeDirectory


                                                                    if(allAlbums[0].title != "undefined"){
                                                                       allAlbumsModel.model = allAlbums
                                                                    }
                                                                }

                                                            }
                                                        }
                                                    }
                                                }

                        }
                    }
                }
            }
        }


        Repeater {
                    model: !navDrawer.enabled ? sections : 0

                    delegate: Tab {
                        title: sectionTitles[index]

                        property string selectedComponent: modelData[0]
                        property var section: modelData

                        sourceComponent: tabDelegate
                    }
                }


        Loader {
            id: smallLoader
                       anchors.fill: parent
                       sourceComponent: tabDelegate

                       property var section: []
                       visible: active
                       active: false
        }
    }

    Dialog {
        id: settingsDialog
        title: "Settings"
        height: dp(400)
        width: dp(600)
        positiveButtonText: "Save"

        Loader {
            height: dp(400)
            width: dp(600)
            anchors.fill: parent
            //anchors.bottomMargin: dp(100)
            asynchronous: true
            visible: true
            source: Qt.resolvedUrl("SettingsDemo.qml")

        }
        //Component.onCompleted: visible = false
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a folder"
        folder: shortcuts.home
        selectFolder: true
        selectMultiple: false
        onAccepted: {
            console.log("You chose: " + fileDialog.fileUrls)
            musicFolder.getMusicFolder = fileDialog.fileUrls[0].toString()
            console.log(musicFolder.getMusicFolder)
            fileDialog.close()

        }
        onRejected: {
            console.log("Canceled")
            fileDialog.close()
        }
        Component.onCompleted: visible = false
    }

    Dialog {
        id: colorPicker
        title: "Pick color"

        positiveButtonText: "Done"

        MenuField {
            id: selection
            model: ["Primary color", "Accent color", "Background color"]
            width: dp(160)
        }

        Grid {
            columns: 7
            spacing: dp(8)

            Repeater {
                model: [
                    "red", "pink", "purple", "deepPurple", "indigo",
                    "blue", "lightBlue", "cyan", "teal", "green",
                    "lightGreen", "lime", "yellow", "amber", "orange",
                    "deepOrange", "grey", "blueGrey", "brown", "black",
                    "white"
                ]

                Rectangle {
                    width: dp(30)
                    height: dp(30)
                    radius: dp(2)
                    color: Palette.colors[modelData]["500"]
                    border.width: modelData === "white" ? dp(2) : 0
                    border.color: Theme.alpha("#000", 0.26)

                    Ink {
                        anchors.fill: parent

                        onPressed: {
                            switch(selection.selectedIndex) {
                                case 0:
                                    theme.primaryColor = parent.color
                                    var db = LocalStorage.openDatabaseSync("vinylmusic", "1.0", "The Example QML SQL!", 1000000);
                                    db.transaction(
                                        function(tx) {
                                            // Create the database if it doesn't already exist
                                            tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(id INT PRIMARY KEY AUTOINCREMENT, setting TEXT, value TEXT)');

                                            var rs = tx.executeSql('SELECT * FROM Settings WHERE setting="primaryColor"')
                                            if(rs.rows.length > 0){
                                                tx.executeSql('UPDATE Settings SET value="' + theme.primaryColor + '" WHERE id=' + rs.rows.item(0).id);

                                            }else{
                                                tx.executeSql('INSERT INTO Settings VALUES (NULL, ?, ?)',  [ 'primaryColor', theme.primaryColor ]);
                                            }

                                        })
                                    break;
                                case 1:
                                    theme.accentColor = parent.color
                                    break;
                                case 2:
                                    theme.backgroundColor = parent.color
                                    break;
                            }
                        }
                    }
                }
            }
        }

        onRejected: {
            // TODO set default colors again but we currently don't know what that is
        }
    }

    Component {
        id: tabDelegate

        Item {
            Sidebar {
                id: sidebar

                expanded: !navDrawer.enabled && selectedComponent != 'Activity'

                Column {
                    width: parent.width

                    Repeater {
                        model: section
                        delegate: ListItem.Subtitled {

                            text: modelData
                            selected: modelData == selectedComponent
                            action: IconButton {

                                    iconName: {
                                        if(modelData == 'Albums'){
                                        return 'av/album'
                                        }else if(modelData == 'Artists'){
                                            return 'social/person'
                                        }else if(modelData == 'All Music'){
                                            return 'av/queue_music'
                                        }else if(modelData == 'Streams'){
                                            return 'social/public'
                                        }else if(modelData == 'Settings'){
                                            return 'action/settings'
                                        }else if(modelData == 'Profile'){
                                            return 'social/person'
                                        }else if(modelData == 'Activity'){
                                            return 'action/dashboard'
                                        }else if(modelData == 'Discover'){
                                            return 'action/language'
                                        }else if(modelData == 'Messages'){
                                            return 'communication/chat'
                                        }

                                    }
                                    anchors.topMargin: dp(20)
                                    height:dp(36)
                                    width:dp(12)
                                    anchors.horizontalCenter: parent.horizontalCenter

                            }

                            height:dp(42)

                            onClicked: {
                                Global.playedSongs = []
                                if(modelData == 'Profile'){
                                 console.log("loading profile")
                                }else{

                                selectedComponent = modelData
                                }
                                folderModel.folder = "file://" + homeDirectory
                                albumFolder.folder = "file://" + homeDirectory
                            }

                        }
                    }
                }
            }
            Flickable {
                id: flickable
                anchors {
                    left: sidebar.right
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                }
                clip: true
                contentHeight: Math.max(example.implicitHeight + 40, height)
                Loader {
                    id: example
                    anchors.fill: parent
                    anchors.bottomMargin: dp(100)
                    asynchronous: true
                    visible: status == Loader.Ready
                    // selectedComponent will always be valid, as it defaults to the first component

                    source: {

                        if (navDrawer.enabled) {
                            return Qt.resolvedUrl("%1Demo.qml").arg(demo.selectedComponent.replace(" ", ""))
                        } else {
                            return Qt.resolvedUrl("%1Demo.qml").arg(selectedComponent.replace(" ", ""))
                        }

                    }

                }


                ProgressCircle {
                    anchors.centerIn: parent
                    visible: example.status == Loader.Loading
                }
            }
            Scrollbar {
                flickableItem: flickable
            }
        }
    }


    Rectangle {
        color:'#fff'
        height:dp(100)
        width:parent.width
        anchors.bottom: parent.bottom
        border.width: modelData === "white" ? dp(2) : 0
        border.color: Theme.alpha("#aaa", 0.26)

        Rectangle {
            color:'#fff'
            height:50
        }

        Label {
            id: songPlaying
            text: "Nothing playing"
            //anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            height:dp(60)
            anchors.left: seeker.left
            width:dp(100)
            color: Theme.light.textColor
        }

        Slider {
            id: seeker
            width: {
                return parseInt(parent.width - 50)
            }
            anchors.horizontalCenter: parent.horizontalCenter
            height:50
            value: 0
            darkBackground: index == 1
            updateValueWhileDragging: true
            color:theme.primaryColor
            anchors.rightMargin: dp(50)
            anchors.leftMargin:dp(50)
            anchors.bottomMargin:dp(190)

            onValueChanged: {
                if(seeker.pressed){
                    durationTimer.stop()
                    playMusic.pause()
                    var newseek = parseInt(seeker.value * 1)
                    playMusic.seek(newseek)
                    playMusic.play()
                    durationTimer.start()
                }
            }
        }



        Rectangle {

            anchors.bottomMargin: dp(-5)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            height:dp(60)
            width:dp(210)

            IconButton {
                iconName: 'av/skip_previous'

                id: prevButton
                anchors.left: parent.left
                anchors.rightMargin: dp(60)
                size: dp(30)
                onClicked: {
                    getPrevTrack()
                }
                color: {
                    return Theme.light.textColor
                }
            }

            IconButton {
                iconName: 'av/play_arrow'
                id: playButton1
                anchors.left: prevButton.right
                anchors.leftMargin: dp(30)
                size: dp(30)
                onClicked: {
                    playTriggerAction()
                }
                color: {
                    return Theme.light.textColor
                }

            }

            IconButton {
                iconName: 'av/skip_next'
                color: {
                    return Theme.light.textColor
                }

                id: nextButton
                anchors.left: playButton1.right
                anchors.leftMargin: dp(30)
                size: dp(30)

                onClicked: {
                        getNextTrack()

                }
            }

        }


    }

    Rectangle {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: dp(10)
            anchors.right: parent.right
            anchors.rightMargin:dp(30)
            height:dp(40)
            width:dp(150)
            Component.onCompleted: {
                if(filePathName){
                    folderModel.folder = loadedFileFolder.toString()
                    albumFolder.folder = loadedFileFolder.toString()
                    playMusic.source = 'file://' + filePathName
                    playMusic.play()
                }
            }

            IconButton {
                id: shuffleButton
                iconName: {
                    return 'av/shuffle'
                }

                anchors.topMargin: dp(-60)
                anchors.right: parent.left
                anchors.rightMargin: dp(20)

                color: {
                    if(Global.shuffle){
                        return theme.primaryColor;
                    }else{
                        return Theme.light.textColor
                    }
                }
                Component.onCompleted: {
                    msg.author = "Nick"
                    aa.getAlbums = "New Album"
                    console.log(aa.getAlbums);

                    Global.mode = allSongObjects
                    var db = LocalStorage.openDatabaseSync("vinylmusic", "1.0", "The Example QML SQL!", 1000000);
                    db.transaction(
                        function(tx) {
                            // Create the database if it doesn't already exist
                            tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(id INTEGER PRIMARY KEY AUTOINCREMENT, setting TEXT, value TEXT)');
                            // Show all added greetings
                            var rs = tx.executeSql('SELECT * FROM Settings WHERE setting="shuffle"');
                            var r = ""

                            if(rs.rows.length > 0){
                                for(var i = 0; i < rs.rows.length; i++) {
                                    r += rs.rows.item(i).setting + ", " + rs.rows.item(i).value + "\n"
                                }
                                console.log(r)
                                console.log(rs.rows.item(0).value)
                                Global.shuffle = rs.rows.item(0).value
                                if( rs.rows.item(0).value){
                                    shuffleButton.color = theme.primaryColor;
                                }else{
                                    shuffleButton.color = Theme.light.textColor
                                }
                            }else{
                                Global.shuffle = false;
                            }



                        })
                }


                onClicked: {
                    Global.shuffle = !Global.shuffle
                    if(Global.shuffle){
                        this.color = theme.primaryColor;
                    }else{
                        this.color = Theme.light.textColor
                    }

                    var db = LocalStorage.openDatabaseSync("vinylmusic", "1.0", "The Example QML SQL!", 1000000);
                    db.transaction(
                        function(tx) {
                            // Create the database if it doesn't aGlobal.shufflelready exist
                            tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(id INT PRIMARY KEY AUTOINCREMENT, setting TEXT, value TEXT)');

                            var rs = tx.executeSql('SELECT * FROM Settings WHERE setting="shuffle"')
                            if(rs.rows.length > 0){
                                tx.executeSql('UPDATE Settings SET value="' + Global.shuffle + '" WHERE id=' + rs.rows.item(0).id);

                            }else{
                                tx.executeSql('INSERT INTO Settings VALUES (NULL, ?, ?)',  [ 'shuffle', Global.shuffle ]);
                            }

                        })
                }

            }

            IconButton {
                anchors.bottom: parent.bottom
                id: volumeIcon
                iconName: 'av/volume_up'
                anchors.top: shuffleButton.top
                anchors.topMargin: dp(-16)
                color: index == 0 ? Theme.light.textColor : Theme.dark.textColor
                onClicked: {
                    if(volumeControl.value == 0.00){
                        volumeControl.value = 1
                        this.iconName = 'av/volume_up'
                        this.color = Theme.light.textColor

                    }else{
                        volumeControl.value = 0.00
                        this.iconName = 'av/volume_off'
                        this.color = theme.primaryColor //Theme.alpha('#f33', .9)
                    }
                }
            }


            Slider {
                id: volumeControl
                width: dp(100)
                anchors.topMargin: dp(110)
                anchors.right: parent.right
                updateValueWhileDragging: true
                color:theme.primaryColor
                value: 1.0
                onValueChanged: {
                    if(this.value == 0.00){
                        volumeIcon.iconName = 'av/volume_off'
                        volumeIcon.color = theme.primaryColor //Theme.alpha('#f33', .9)

                    }else if(this.value > 0.00 && this.value <= 0.60){
                        volumeIcon.iconName = 'av/volume_down'
                        volumeIcon.color = Theme.light.textColor
                    }else{
                        volumeIcon.iconName = 'av/volume_up'
                        volumeIcon.color = Theme.light.textColor
                    }
                    playMusic.volume = this.value
                }
                Component.onCompleted: {

                        initScan.start();
                }
            }




        }
}
