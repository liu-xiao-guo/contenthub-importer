import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Content 0.1

/*!
    \brief MainView with a Label and Button elements.
*/

MainView {
    id: root
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "com.ubuntu.developer.liu-xiao-guo.contenthub-importer"

    /*
     This property enables the application to change orientation
     when the device is rotated. The default is false.
    */
    //automaticOrientation: true

    // Removes the old toolbar and enables new features of the new header.
    //    useDeprecatedToolbar: false

    width: units.gu(50)
    height: units.gu(75)

    property list<ContentItem> importItems
    property var activeTransfer

    Page {
        title: i18n.tr("ContentHub importer")

        ContentPeer {
            id: picSourceSingle
            contentType: ContentType.Pictures
            handler: ContentHandler.Source
            selectionType: ContentTransfer.Single
        }

        ContentPeer {
            id: picSourceMulti
            contentType: ContentType.Pictures
            handler: ContentHandler.Source
            selectionType: ContentTransfer.Multiple
        }

        // Optional store to use for persistent storage of content
        ContentStore {
            id: appStore
            scope: ContentScope.App
        }

        // Provides a list<ContentPeer> suitable for use as a model
        ContentPeerModel {
            id: picSources
            // Type of handler: Source, Destination, or Share
            handler: ContentHandler.Source
            // well know content type
            contentType: ContentType.Pictures
        }

        ListModel {
            id: typemodel
            ListElement { name: "Import single item" }
            ListElement { name: "Import multiple items" }
        }

        ListItem.Empty {
            id: options

            Text {
                id: title
                text: "Import single item"
            }

            CheckBox {
                anchors.left: title.right
                anchors.leftMargin: units.gu(1)
                text: "Import single item"
                checked: true

                onClicked: {
                    console.log("triger value: " + checked );

                    if (checked) {
                        activeTransfer = picSourceSingle.request(appStore);
                    } else {
                        activeTransfer = picSourceMulti.request(appStore);
                    }
                }
            }

            Button {
                anchors {
                    right: parent.right
                    margins: units.gu(2)
                }
                text: "Finalize import"
                enabled: activeTransfer.state === ContentTransfer.Collected
                onClicked: activeTransfer.finalize()
            }

        }

        ListView {
            id: peerList
            anchors {
                left: parent.left
                right: parent.right
                top: options.bottom
            }
            height: childrenRect.height
            model: picSources.peers

            delegate: ListItem.Standard {
                text: modelData.name
                control: Button {
                    text: "Import"
                    onClicked: {
                        // Request the transfer, it needs to be created and dispatched from the hub
                        activeTransfer = modelData.request();
                    }
                }
            }
        }

        ListView {
            id: resultList
            anchors {
                left: parent.left
                right: parent.right
                top: peerList.bottom
            }

            height: childrenRect.height

            model: importItems
            delegate: ListItem.Empty {
                id: result
                height: 200
                UbuntuShape {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: image.width
                    height: image.height

                    // Display the image if any
                    image: Image {
                        id: image
                        source: {
                            console.log("url: " + url);
                            return url;
                        }
                        height: result.height
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                // Display the text if any
                Text {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: units.gu(0.5)
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: model.text; // we should use model.text instead of text,
                                      // which is already a property of Text

                }
            }
        }

        // Provides overlay showing another app is being used to complete the request
        // formerly named ContentImportHint
        ContentTransferHint {
            anchors.fill: parent
            activeTransfer: activeTransfer
        }

        Connections {
            target: activeTransfer
            onStateChanged: {
                switch (activeTransfer.state) {
                case ContentTransfer.Created:
                    console.log("Created");
                    break
                case ContentTransfer.Initiated:
                    console.log("Initiated");
                    break;
                case ContentTransfer.InProgress:
                    console.log("InProgress");
                    break;
                case ContentTransfer.Downloading:
                    console.log("Downloading");
                    break;
                case ContentTransfer.Downloaded:
                    console.log("Downloaded");
                    break;
                case ContentTransfer.Charged:
                    console.log("Charged");
                    break;
                case ContentTransfer.Collected:
                    console.log("Collected");
                    break;
                case ContentTransfer.Aborted:
                    console.log("Aborted");
                    break;
                case ContentTransfer.Finalized:
                    console.log("Finalized");
                    break;
                default:
                    console.log("not recognized state!")
                    break;
                }

                if (activeTransfer.state === ContentTransfer.Charged) {
                    importItems = activeTransfer.items;

                    console.log("imported items: " + importItems.length);

                    for ( var i = 0; i < importItems.length; i ++ ) {
                        console.log("imported url: " + importItems[i].url);
                        console.log("imported text: " + importItems[i].text);
                    }

//                    var item;
//                    for ( item in importItems ) {
//                        console.log( "imported url: " + importItems[item].url);
//                    }
                }
            }
        }
    }
}
