import QtQuick 2.0
import FlightGear.Launcher 1.0
import "."

Item {
    id: root
    property bool advanced: false
    property string description: ""
    property string label: ""
    property var keywords: []
    property bool enabled: true
    property string option: ""
    property string setting: ""

    // define a new visiblity property so we can control built-in 'visible' ourselves
    property bool hidden: false

    implicitHeight: childrenRect.height
    implicitWidth: parent.width // which is assumed to be the section
    visible: {
        // override so advanced items show up in searches
        if (_launcher.isSearchActive && _launcher.matchesSearch(_launcher.settingsSearchTerm, keywords)) {
            return true;
        }

        return !hidden && (!advanced || parent.showAdvanced)
    }

    readonly property bool __isDefault: (this.value == this.defaultValue);

    Component.onCompleted: {
        restoreState();
    }

    Connections {
        // only invoke apply if 'option' is set, otherwise we assume
        // there is specialised apply code
        target: root.option != "" ? _config : null

        // this requires Qt 5.7, so we simulate it
       // enabled: root.option != ""

        onCollect: apply();
    }

    Rectangle {
        // this is the 'search hit highlight effect'
        anchors.fill: parent
        radius: Style.margin
        border.color: "yellow"
        border.width: 1
        color: "#ffff7f"

        z: -1
        visible: _launcher.isSearchActive && _launcher.matchesSearch(_launcher.settingsSearchTerm, keywords)
    }

    function apply()
    {
        console.warn("Implement apply() on " + root.setting)
    }

    function saveState()
    {
        if (this.hasOwnProperty("value")) {
            _config.setValueForKey("", root.setting, this.value)
        } else {
            console.warn("No value property on " + this);
        }
    }

    function restoreState()
    {
        if (root.setting == "") {
            console.warn("Missing setting key on " + label)
            return;
        }

        if (!"value" in root) {
            console.warn("No value property on " + root);
            return;
        }

        var defaultValue = ("defaultValue" in root) ? root.defaultValue : undefined;
        var rawValue = _config.getValueForKey("", root.setting, defaultValue);
      // console.warn("restoring state for " + root.setting + ", got raw value " + rawValue + " with type " + typeof(rawValue))
        if (rawValue != undefined) {
           // root["value"] = rawValue
            this.value = rawValue
        }
    }
}