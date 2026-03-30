import QtQuick
import QtCore
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Qt5Compat.GraphicalEffects

MouseArea {
    id: root
    required property LockContext context

    property string currentView: "clock"
    property bool showLoginView: currentView === "login"
    property bool hasAttemptedUnlock: false
    property bool ctrlHeld: false

    readonly property string wallpaperPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/current_wallpaper"
    readonly property string userHome: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    readonly property string userName: {
        const parts = userHome.split("/");
        return parts.length > 0 ? parts[parts.length - 1] : "User";
    }

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    focus: true

    Rectangle {
        anchors.fill: parent
        color: "#101010"
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.wallpaperPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        smooth: true
        cache: true
    }

    FastBlur {
        anchors.fill: parent
        source: wallpaper
        radius: 32
    }


    Rectangle {
        id: smokeOverlay
        anchors.fill: parent
        color: "#66000000"
        opacity: root.showLoginView ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 350
                easing.type: Easing.OutCubic
            }
        }
    }

    Item {
        id: clockView
        anchors.fill: parent
        opacity: root.showLoginView ? 0 : 1
        visible: opacity > 0
        scale: root.showLoginView ? 0.92 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 450
                easing.type: Easing.OutBack
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -80
            spacing: 8

            Text {
                id: clockText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatTime(new Date(), "hh:mm")
                font.pixelSize: 108
                font.weight: Font.DemiBold
                color: "#f5f5f5"

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 3
                    radius: 16
                    samples: 33
                    color: "#7f000000"
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }

            Text {
                id: dateText
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDate(new Date(), "dddd, d MMMM")
                font.pixelSize: 22
                color: "#f2f2f2"

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 8
                    samples: 17
                    color: "#66000000"
                }

                Timer {
                    interval: 60000
                    running: true
                    repeat: true
                    onTriggered: dateText.text = Qt.formatDate(new Date(), "dddd, d MMMM")
                }
            }
        }

        Text {
            id: hintText
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Press any key or click to unlock"
            font.pixelSize: 18
            color: "#c8ffffff"
            opacity: hintOpacity
            property real hintOpacity: 0.7

            Timer {
                id: hintFadeTimer
                interval: 4000
                running: clockView.visible
                onTriggered: hintText.hintOpacity = 0
            }

            Connections {
                target: clockView
                function onVisibleChanged() {
                    if (clockView.visible) {
                        hintText.hintOpacity = 0.7;
                        hintFadeTimer.restart();
                    }
                }
            }

            Behavior on hintOpacity {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutCubic
                }
            }
        }

        Row {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 24
            anchors.rightMargin: 24
            spacing: 10

            Rectangle {
                id: shutdownButton
                width: 96
                height: 36
                radius: 24
                color: shutdownMouse.pressed ? "#88f29d9d" : (shutdownMouse.containsMouse ? "#66ffffff" : "#44ffffff")
                border.color: "#80ffffff"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Shutdown"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8f8f8"
                }

                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchToLogin(root.context.actionShutdown)
                }
            }

            Rectangle {
                id: restartButton
                width: 96
                height: 36
                radius: 24
                color: restartMouse.pressed ? "#889db8f2" : (restartMouse.containsMouse ? "#66ffffff" : "#44ffffff")
                border.color: "#80ffffff"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Reboot"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#f8f8f8"
                }

                MouseArea {
                    id: restartMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.switchToLogin(root.context.actionRestart)
                }
            }
        }
    }

    Item {
        id: loginView
        anchors.fill: parent
        opacity: root.showLoginView ? 1 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: loginContent
            anchors.centerIn: parent
            spacing: 16

            property real animProgress: root.showLoginView ? 1 : 0
            Behavior on animProgress {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }

            Item {
                id: avatarContainer
                Layout.alignment: Qt.AlignHCenter
                width: 100
                height: 100
                opacity: Math.min(1, loginContent.animProgress * 3)
                scale: 0.8 + (0.2 * Math.min(1, loginContent.animProgress * 3))

                Behavior on scale {
                    NumberAnimation {
                        duration: 350
                        easing.type: Easing.OutBack
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: parent.height + 8
                    radius: width / 2
                    color: "transparent"
                    border.color: "#7ec8ff"
                    border.width: 3
                    opacity: 0.85

                    layer.enabled: true
                    layer.effect: DropShadow {
                        horizontalOffset: 0
                        verticalOffset: 4
                        radius: 16
                        samples: 33
                        color: "#66000000"
                    }
                }

                Rectangle {
                    id: avatarCircle
                    anchors.fill: parent
                    radius: width / 2
                    color: "#4f87b5"
                    clip: true

                    Image {
                        id: avatarImage
                        anchors.fill: parent
                        source: "file://" + root.userHome + "/.face"
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.userName.length > 0 ? root.userName.charAt(0).toUpperCase() : "?"
                        font.pixelSize: 40
                        font.weight: Font.Medium
                        color: "#f6fbff"
                        visible: avatarImage.status !== Image.Ready
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                text: root.userName
                font.pixelSize: 22
                font.weight: Font.Medium
                color: "#f5f5f5"
                opacity: Math.min(1, Math.max(0, loginContent.animProgress * 3 - 0.3))

                transform: Translate {
                    y: (1 - Math.min(1, Math.max(0, loginContent.animProgress * 3 - 0.3))) * 15
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root.context.targetAction !== root.context.actionUnlock
                text: root.context.targetAction === root.context.actionShutdown ? "Enter password to shut down" : "Enter password to restart"
                font.pixelSize: 15
                color: "#d6ffffff"
            }

            Rectangle {
                id: passwordContainer
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 12
                width: 300
                height: 52
                radius: height / 2
                color: "#44f5f5f5"
                border.color: loginPasswordField.activeFocus ? "#7ec8ff" : "#88ffffff"
                border.width: loginPasswordField.activeFocus ? 2 : 1
                opacity: Math.min(1, Math.max(0, loginContent.animProgress * 3 - 0.5))
                property real staggerY: (1 - Math.min(1, Math.max(0, loginContent.animProgress * 3 - 0.5))) * 20
                property real shakeOffset: 0

                transform: Translate {
                    x: passwordContainer.shakeOffset
                    y: passwordContainer.staggerY
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 4
                    radius: 12
                    samples: 25
                    color: "#4c000000"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 8
                    spacing: 8

                    TextField {
                        id: loginPasswordField
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: Text.AlignVCenter
                        placeholderText: root.context.showFailure ? "Incorrect password" : "Password"
                        placeholderTextColor: root.context.showFailure ? "#ffb4b4" : "#d0ffffff"
                        color: "#f8f8f8"
                        background: Item {}

                        echoMode: TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData
                        enabled: root.showLoginView && !root.context.unlockInProgress

                        onTextChanged: root.context.currentText = text
                        onAccepted: {
                            root.hasAttemptedUnlock = true;
                            root.context.tryUnlock(root.context.targetAction);
                        }

                        Connections {
                            target: root.context
                            function onCurrentTextChanged() {
                                loginPasswordField.text = root.context.currentText;
                            }
                        }
                    }

                    Rectangle {
                        id: submitButton
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignVCenter
                        radius: width / 2
                        color: submitMouseArea.pressed ? "#5b99cc" : (submitMouseArea.containsMouse ? "#73b3e8" : "#7ec8ff")

                        Text {
                            anchors.centerIn: parent
                            text: "→"
                            font.pixelSize: 20
                            color: "#0f1b26"
                        }

                        MouseArea {
                            id: submitMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.context.unlockInProgress
                            onClicked: {
                                root.hasAttemptedUnlock = true;
                                root.context.tryUnlock(root.context.targetAction);
                            }
                        }
                    }
                }

                SequentialAnimation {
                    id: wrongPasswordShakeAnim
                    NumberAnimation { target: passwordContainer; property: "shakeOffset"; to: -20; duration: 50 }
                    NumberAnimation { target: passwordContainer; property: "shakeOffset"; to: 20; duration: 50 }
                    NumberAnimation { target: passwordContainer; property: "shakeOffset"; to: -10; duration: 40 }
                    NumberAnimation { target: passwordContainer; property: "shakeOffset"; to: 10; duration: 40 }
                    NumberAnimation { target: passwordContainer; property: "shakeOffset"; to: 0; duration: 30 }
                }

                Connections {
                    target: root.context
                    function onShowFailureChanged() {
                        if (root.context.showFailure && root.hasAttemptedUnlock) {
                            wrongPasswordShakeAnim.restart();
                        }
                    }
                }
            }

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                running: root.context.unlockInProgress
                visible: running
                contentItem.implicitWidth: 48
                contentItem.implicitHeight: 48
            }
        }
    }

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            return;
        }

        if (!root.showLoginView) {
            root.switchToLogin(root.context.actionUnlock);
        } else {
            root.forceFieldFocus();
        }
    }

    onPositionChanged: {
        if (root.showLoginView) {
            root.forceFieldFocus();
        }
    }

    function forceFieldFocus(): void {
        if (root.showLoginView && loginView.visible) {
            loginPasswordField.forceActiveFocus();
        }
    }

    function switchToLogin(action): void {
        if (action === undefined) {
            root.context.resetTargetAction();
        } else {
            root.context.targetAction = action;
        }
        root.currentView = "login";
        Qt.callLater(() => loginPasswordField.forceActiveFocus());
    }

    onCurrentViewChanged: {
        if (root.currentView === "clock") {
            root.forceActiveFocus();
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Control) {
            root.ctrlHeld = true;
            return;
        }

        if (event.key === Qt.Key_Escape) {
            if (root.context.currentText.length > 0) {
                root.context.currentText = "";
            } else if (root.showLoginView) {
                root.currentView = "clock";
                root.context.resetTargetAction();
            }
            event.accepted = true;
            return;
        }

        if (!root.showLoginView) {
            root.switchToLogin(root.context.actionUnlock);
            const inputChar = event.text;
            Qt.callLater(() => {
                loginPasswordField.forceActiveFocus();
                if (inputChar.length === 1 && inputChar.charCodeAt(0) >= 32) {
                    loginPasswordField.text += inputChar;
                }
            });
            return;
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (root.context.currentText.length > 0) {
                root.hasAttemptedUnlock = true;
                root.context.tryUnlock(root.context.targetAction);
            }
            event.accepted = true;
            return;
        }

        if (!loginPasswordField.activeFocus) {
            loginPasswordField.forceActiveFocus();
        }
    }

    Keys.onReleased: event => {
        if (event.key === Qt.Key_Control) {
            root.ctrlHeld = false;
        }
        forceFieldFocus();
    }

    Component.onCompleted: {
        root.currentView = "clock";
        root.hasAttemptedUnlock = false;
        Qt.callLater(() => root.forceActiveFocus());
    }
}
