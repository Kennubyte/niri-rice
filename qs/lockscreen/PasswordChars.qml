import QtQuick

Flickable {
    id: root
    required property int length

    clip: true
    interactive: false
    boundsBehavior: Flickable.StopAtBounds
    contentWidth: dotsRow.implicitWidth
    contentHeight: height
    contentX: Math.max(contentWidth - width, 0)

    Behavior on contentX {
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: dotsRow
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 4
        }
        spacing: 10

        Repeater {
            model: root.length

            delegate: Item {
                required property int index
                implicitWidth: 14
                implicitHeight: 14

                Rectangle {
                    id: glyph
                    anchors.centerIn: parent
                    width: index % 3 === 1 ? 16 : 12
                    height: index % 3 === 0 ? 12 : (index % 3 === 1 ? 8 : 12)
                    radius: index % 3 === 2 ? 0 : height / 2
                    color: "#dff4ff"
                    opacity: 1
                    scale: 0.84
                    rotation: index % 3 === 2 ? 45 : 0

                    Behavior on scale {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Component.onCompleted: glyph.scale = 1
                }
            }
        }
    }
}
