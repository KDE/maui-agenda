import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import org.mauikit.controls as Maui
import org.mauikit.calendar as Cal

Maui.ApplicationWindow
{
    id: root

    Maui.PopupPage
    {
        id: _eventDialog
        persistent: true
        headBar.visible: false

        actions: [

            Action
            {
                text: i18n("Cancel")
                onTriggered: _eventDialog.close()
            },

            Action
            {
                text: i18n("Create")
                onTriggered:
                {
                    Cal.CalendarManager.addIncidence(_eventPage.incidence)
                }
            }
        ]

        stack: Cal.EventPage
        {
            id: _eventPage
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Action
    {
        id: _newEventAction
        text: "New event"
        icon.name: "new-event"
        onTriggered: _eventDialog.open()
    }

    Maui.SideBarView
    {
        id: _sideBarView
        anchors.fill: parent
        sideBar.autoHide: true

        sideBarContent:  Maui.Page
        {
            anchors.fill: parent
            Maui.Theme.colorSet: Maui.Theme.Window

            headBar.leftContent: [
                Maui.ToolButtonMenu
                {
                    icon.name: "application-menu"

                    MenuItem
                    {
                        contentItem: Column
                        {
                            Repeater
                            {
                                model: Cal.CalendarManager.collections
                                delegate: MenuItem
                                {
                                    width: parent.width
                                    checkable: true
                                    text: model.display

                                    checked: model.checkState === 2
                                    onTriggered: model.checkState = model.checkState === 0 ? 2 : 0

                                }
                            }
                        }
                    }

                    MenuItem
                    {
                        text: i18n("Settings")
                        icon.name: "settings-configure"
                    }

                    MenuItem
                    {
                        text: i18n("About")
                        icon.name: "documentinfo"
                        onTriggered: Maui.App.aboutDialog()
                    }
                }

            ]

            headBar.rightContent: [
                ToolButton
                {
                    action: _newEventAction
                }
            ]

            Maui.ListBrowser
            {
                anchors.fill: parent
                holder.visible: count === 0

                holder.emoji: "view-calendar"
                holder.title: i18n("Empty!")
                holder.body: "No events for this day"

                model: Cal.IncidenceOccurrenceModel
                {
                    id: _eventsModel
                    start: _stackView.currentItem.selectedDate
                    length: 0
                    calendar: Cal.CalendarManager.calendar
                    filter: Cal.Filter
                }

                delegate: Maui.ListBrowserDelegate
                {
                    width: ListView.view.width

                    property var data : model.incidences
                    label1.text: model.summary
                    label2.text: model.startTime.toLocaleTimeString()
                }

                header: Item
                {
                    width: parent.width
                    height: _cardlayout.height + Maui.Style.space.medium

                    Pane
                    {
                        id: _cardlayout

                        width: parent.width
                        height: implicitContentHeight + topPadding + bottomPadding

                        padding: Maui.Style.space.medium

                        background: Rectangle
                        {
                            radius: Maui.Style.radiusV
                            color: Maui.Theme.alternateBackgroundColor
                        }

                        contentItem: ColumnLayout
                        {
                            spacing: Maui.Style.space.medium

                            Pane
                            {
                                implicitWidth: Math.max(implicitContentWidth+ leftPadding + rightPadding, height)
                                implicitHeight: implicitContentHeight + topPadding + bottomPadding

                                padding: Maui.Style.space.medium

                                background: Rectangle
                                {
                                    color: Maui.Theme.backgroundColor
                                    radius: Maui.Style.radiusV
                                }

                                contentItem: Label
                                {
                                    horizontalAlignment: Qt.AlignHCenter
                                    color:"orange"
                                    text: _eventsModel.start.getDate()
                                    font.bold: true
                                    font.weight: Font.Black
                                    font.pointSize: 32
                                }
                            }

                            Label
                            {
                                Layout.fillWidth: true
                                text: Qt.formatDateTime(_eventsModel.start, "MMM yyyy")
                                font.bold: true
                                font.weight: Font.DemiBold
                                font.pointSize: 12
                            }
                        }
                    }

                }
            }
        }

        Maui.Page
        {
            anchors.fill: parent
            Maui.Controls.showCSD: true
            title: _stackView.currentItem.title
            headBar.background: null
            headBar.leftContent: [
                ToolButton
                {
                    icon.name: checked ? "sidebar-collapse" : "sidebar-expand"
                    onClicked: _sideBarView.sideBar.toggle()
                    checked: _sideBarView.sideBar.visible
                },

                ToolButton
                {
                    icon.name: "go-previous"
                    onClicked: _stackView.pop()
                    visible: _stackView.depth === 2
                    text: _yearView.title
                }
            ]

            headBar.rightContent: Maui.ToolActions
            {
                autoExclusive: false
                checkable: false
                display: ToolButton.IconOnly

                Action
                {
                    icon.name: "go-previous"
                    text: i18n("Previous Year")
                    shortcut: "Left"
                    onTriggered: _stackView.currentItem.previousDate()
                }

                Action
                {
                    icon.name: "go-jump-today"
                    text: i18n("Today")
                    onTriggered: _stackView.currentItem.resetDate()
                }

                Action
                {
                    icon.name: "go-next"
                    text: i18n("Next Year")
                    shortcut: "Right"
                    onTriggered: _stackView.currentItem.nextDate()
                }
            }

            StackView
            {
                id:_stackView
                anchors.fill: parent
                clip: true

                initialItem: Cal.YearView
                {
                    id: _yearView
                    onMonthClicked: (date) =>
                                    {
                                        _stackView.push(_monthViewComponent)
                                        _stackView.currentItem.setToDate(_stackView.currentItem.addMonthsToDate(date, -1))
                                    }
                }


                Component
                {
                    id: _monthViewComponent
                    Cal.MonthView
                    {
                        onDateDoubleClicked: _eventDialog.open()
                    }
                }



                pushExit: Transition
                {
                    ParallelAnimation
                    {
                        PropertyAnimation
                        {
                            property: "scale"
                            from: 1
                            to: 4
                            duration: 200
                            easing.type: Easing.InOutCubic
                        }

                        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.InOutCubic }
                    }

                }

                pushEnter: Transition
                {
                    ParallelAnimation
                    {
                        PropertyAnimation
                        {
                            //                        target: _yearView.gridView.currentItem
                            property: "scale"
                            from: 0
                            to: 1
                            duration: 200
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                popEnter: Transition
                {
                    ParallelAnimation
                    {
                        PropertyAnimation
                        {
                            //                        target: _yearView.gridView.currentItem
                            property: "scale"
                            from: 4
                            to: 1
                            duration: 200
                            easing.type: Easing.InOutCubic
                        }

                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.InOutCubic }
                    }
                }

                popExit: Transition
                {
                    ParallelAnimation
                    {
                        PropertyAnimation
                        {
                            //                        target: _yearView.gridView.currentItem
                            property: "scale"
                            from: 1
                            to: 0
                            duration: 200
                            easing.type: Easing.OutCubic
                        }

                        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 200; easing.type: Easing.OutCubic }
                    }

                }
            }
        }

    }

}
