import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.welcome as Welcome

Kirigami.ScrollablePage {
    id: root
    title: "Workflows"

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.largeSpacing

        Label {
            text: "Explore different workflows to improve your productivity. Click any option to setup all applications used by the workflow."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        GridLayout {
            id: grid
            columns: 2
            rowSpacing: Kirigami.Units.largeSpacing
            columnSpacing: Kirigami.Units.largeSpacing
            width: parent.width

            Repeater {
                model: [
                    {
                        icon: "/usr/lib/Workflows/astro.svg",
                        title: "Astronomy",
                        description: "Workflow for the exploration of the heavens, capturing, and processing of astronomical data.",
                        script: "github.qkmaxware.callisto.workflow-astro-install.desktop"
                    },
                    {
                        icon: "/usr/lib/Workflows/creative.svg",
                        title: "Creative",
                        description: "Workflow for the creative types. Software for 2d/3d art, music, video production and more.",
                        script: "github.qkmaxware.callisto.workflow-creative-install.desktop"
                    }
                ]

                delegate: Kirigami.Card {
                    Layout.fillWidth: true

                    // 👇 Makes the whole card clickable
                    onClicked: Welcome.Utils.runCommand("/usr/share/applications/" + modelData.script)

                    hoverEnabled: true

                    contentItem: ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        RowLayout {
                            spacing: Kirigami.Units.smallSpacing

                            Image {
                                source: modelData.icon
                                Layout.preferredWidth: Kirigami.Units.iconSizes.large
                                Layout.preferredHeight: Kirigami.Units.iconSizes.large
                                fillMode: Image.PreserveAspectFit
                            }

                            ColumnLayout {
                                spacing: Kirigami.Units.smallSpacing

                                Kirigami.Heading {
                                    text: modelData.title
                                    level: 3
                                    Layout.fillWidth: true
                                }

                                Label {
                                    text: modelData.description
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
