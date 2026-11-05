import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    property int stage: 0

    // Farby
    readonly property color cyanPrimary: "#00f0ff"
    readonly property color cyanDim: "#003a40"
    readonly property color cyanGlow: Qt.rgba(0.0, 0.94, 1.0, 0.35)
    readonly property color alertGreen: "#00ff88"
    readonly property color alertRed: "#ff003c"

    color: "#01080e"

    // =========================================================
    // LOGIKA PRE NÁHODNÉ OVEROVANIE PRSTOV
    // =========================================================
    property var fingerOrder: [0, 1, 2, 3, 4]
    signal verifyFinger(int idx)

    Component.onCompleted: {
        for (var i = fingerOrder.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var temp = fingerOrder[i];
            fingerOrder[i] = fingerOrder[j];
            fingerOrder[j] = temp;
        }
    }

    Timer {
        id: verificationTimer
        interval: 650
        running: true
        repeat: true
        property int step: 0
        onTriggered: {
            if (step < fingerOrder.length) {
                root.verifyFinger(fingerOrder[step]);
                step++;
            } else {
                running = false;
            }
        }
    }

    // =========================================================
    // 1. POZADIE: GIGANTICKÁ BEŽIACA KONZOLA + CLONA
    // =========================================================
    ListModel { id: bgTerminalModel }

    Timer {
        interval: 65
        running: true
        repeat: true
        onTriggered: {
            var hex1 = Math.floor(Math.random() * 0xFFFFFFFF).toString(16).toUpperCase().padStart(8, '0');
            var hex2 = Math.floor(Math.random() * 0xFFFFFFFF).toString(16).toUpperCase().padStart(8, '0');
            var hash1 = Math.floor(Math.random() * 0xFFFFFFFFFFFFFFFF).toString(16).toUpperCase().padStart(16, '0');
            var hash2 = Math.floor(Math.random() * 0xFFFFFFFFFFFFFFFF).toString(16).toUpperCase().padStart(16, '0');
            var uuid = "UUID-" + Math.floor(Math.random() * 9999).toString().padStart(4, '0') + "-" + Math.floor(Math.random() * 9999).toString().padStart(4, '0');

            var paths = [
                "/sys/class/drm/card0/renderD128",
                "/dev/nvme0n1p2/encrypted_volume",
                "/usr/lib/systemd/systemd-journald",
                "/run/user/1000/wayland-0.lock",
                "/kernel/debug/tracing/trace_pipe"
            ];
            var actions = [
                "DECRYPTING THREAD",
                "ALLOCATING SECTOR",
                "MOUNTING VOLUME  ",
                "BYPASSING PROXY  ",
                "PARSING NODE SYS "
            ];
            var statuses = [
                "SECURE_ENCLAVE_ACTIVE",
                "QUANTUM_LOCK_ENGAGED ",
                "DATA_STREAM_VERIFIED ",
                "NEURAL_SYNC_COMPLETE "
            ];

            var act = actions[Math.floor(Math.random() * actions.length)];
            var pth = paths[Math.floor(Math.random() * paths.length)];
            var stat = statuses[Math.floor(Math.random() * statuses.length)];
            var ms = (Math.random() * 1.5).toFixed(3);

            var line = "[ 0x" + hex1 + " ] " + act + " -> " + pth + " | TARGET: {" + uuid + "} | VERIFY_HASH: SHA256:" + hash1 + hash2 + " ... [ OK ] -> MAPPED_BLOCK: " + hex2 + " | LATENCY: " + ms + "ms | STATUS: " + stat;

            bgTerminalModel.append({ "line": line });

            // DYNAMICKÝ POČET RIADKOV PODĽA VÝŠKY OBRAZOVKY (QHD / 4K SAFE)
            var maxBgLines = Math.max(50, Math.ceil(root.height / 20) + 10);
            if (bgTerminalModel.count > maxBgLines) {
                bgTerminalModel.remove(0);
            }
            bgTerminalView.positionViewAtEnd();
        }
    }

    ListView {
        id: bgTerminalView
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        model: bgTerminalModel
        interactive: false
        clip: true
        delegate: Text {
            text: model.line
            color: root.cyanPrimary
            font.family: "Monospace"
            font.pixelSize: 20
            font.bold: true
            opacity: 0.40
            wrapMode: Text.NoWrap
        }
    }

    // Tmavá clona
    Rectangle {
        anchors.fill: parent
        color: "#01080e"
        opacity: 0.60
    }

    // HUD mriežka
    Item {
        anchors.fill: parent
        opacity: 0.10
        Repeater {
            model: Math.ceil(parent.width / 70)
            Rectangle {
                x: index * 70
                y: 0
                width: 1
                height: root.height
                color: root.cyanPrimary
            }
        }
        Repeater {
            model: Math.ceil(parent.height / 70)
            Rectangle {
                x: 0
                y: index * 70
                width: root.width
                height: 1
                color: root.cyanPrimary
            }
        }
    }

    // =========================================================
    // 2. SIMULÁCIA REALISTICKÉHO NAČÍTAVANIA PERCENT
    // =========================================================
    property real visualProgress: 0
    SequentialAnimation on visualProgress {
        running: true
        NumberAnimation {
            to: 42
            duration: 900
            easing.type: Easing.OutCubic
        }
        PauseAnimation {
            duration: 600
        }
        NumberAnimation {
            to: 78
            duration: 800
            easing.type: Easing.InOutSine
        }
        PauseAnimation {
            duration: 800
        }
        NumberAnimation {
            to: 100
            duration: 1500
            easing.type: Easing.OutQuad
        }
    }

    // =========================================================
    // 3. HORNÝ STATUS BANNER
    // =========================================================
    property var statusMessages: [
        "INITIALIZING SYSTEM",
        "SCANNING BIOMETRIC DATA",
        "IDENTIFYING IDENTITY",
        "IDENTITY OK // VERIFIED",
        "ACCESS GRANTED // WELCOME OPERATOR"
    ]
    property int statusIndex: 0
    property string dots: ""
    property int dotCounter: 0

    Timer {
        interval: 300
        running: true
        repeat: true
        onTriggered: {
            dotCounter = (dotCounter + 1) % 4;
            if (dotCounter === 0) dots = "";
            else if (dotCounter === 1) dots = " .";
            else if (dotCounter === 2) dots = " . .";
            else if (dotCounter === 3) dots = " . . .";
        }
    }

    Timer {
        interval: 1800
        running: true
        repeat: true
        onTriggered: {
            if (statusIndex < statusMessages.length - 1) {
                statusIndex++;
            }
        }
    }

    Item {
        id: topBanner
        anchors.top: root.top
        anchors.topMargin: 30
        anchors.horizontalCenter: root.horizontalCenter
        width: 700
        height: 52
        z: 100

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0.08, 0.15, 0.9)
            border.color: statusIndex >= 3 ? root.alertGreen : root.cyanPrimary
            border.width: 1.5

            Rectangle { width: 10; height: 2; color: parent.border.color; anchors.top: parent.top; anchors.left: parent.left }
            Rectangle { width: 2; height: 10; color: parent.border.color; anchors.top: parent.top; anchors.left: parent.left }
            Rectangle { width: 10; height: 2; color: parent.border.color; anchors.top: parent.top; anchors.right: parent.right }
            Rectangle { width: 2; height: 10; color: parent.border.color; anchors.top: parent.top; anchors.right: parent.right }
            Rectangle { width: 10; height: 2; color: parent.border.color; anchors.bottom: parent.bottom; anchors.left: parent.left }
            Rectangle { width: 2; height: 10; color: parent.border.color; anchors.bottom: parent.bottom; anchors.left: parent.left }
            Rectangle { width: 10; height: 2; color: parent.border.color; anchors.bottom: parent.bottom; anchors.right: parent.right }
            Rectangle { width: 2; height: 10; color: parent.border.color; anchors.bottom: parent.bottom; anchors.right: parent.right }

            Row {
                anchors.centerIn: parent
                spacing: 14

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    color: statusIndex >= 3 ? root.alertGreen : root.cyanPrimary
                    anchors.verticalCenter: parent.verticalCenter

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        NumberAnimation { from: 0.1; to: 1.0; duration: 350 }
                        NumberAnimation { from: 1.0; to: 0.1; duration: 350 }
                    }
                }

                Text {
                    text: statusMessages[statusIndex] + (statusIndex < 3 ? dots : "")
                    color: statusIndex >= 3 ? root.alertGreen : root.cyanPrimary
                    font.family: "Monospace"
                    font.pixelSize: 15
                    font.bold: true
                    font.letterSpacing: 2.5
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // =========================================================
    // 4. HLAVNÝ HUD KONTAJNER
    // =========================================================
    ListModel { id: terminalModel }

    property var rawLogs: [
        "[  0.014210 ] INIT: Starting Plasma 6 Kernel Engine....... [ OK ]",
        "[  0.045120 ] ACPI: Power management profile 0x8F0........ [ LOADED ]",
        "[  0.089410 ] BIO-OPTIC: 4K Dermal scan sensor (120Hz)..... [ ONLINE ]",
        "[  0.124891 ] DRM/KWIN: Wayland Compositor pipeline........ [ LOCKED ]",
        "[  0.198203 ] SCANNER: Dermal pattern hash match........... [ 99.98% ]",
        "[  0.291044 ] AUTH: Quantum cryptographic token RSA-4096... [ VALID ]",
        "[  0.342012 ] SHADER: Compiling Plasma 6 graphics pipeline. [ OK ]"
    ]
    property int logCounter: 0

    Timer {
        interval: 110
        running: true
        repeat: true
        onTriggered: {
            if (logCounter < rawLogs.length) {
                terminalModel.append({ "line": rawLogs[logCounter] });
                logCounter++;
            } else {
                var hex = Math.floor(Math.random() * 0xFFFFFF).toString(16).toUpperCase().padStart(6, '0');
                var hash = Math.floor(Math.random() * 0xFFFF).toString(16).toUpperCase().padStart(4, '0');
                var ms = (Math.random() * 0.8 + 0.1).toFixed(2);

                var templates = [
                    "[ SYS_LOG ] DECRYPT: 0x" + hex + " -> Hash SHA-256 [" + hash + "] ... [ OK ]",
                    "[ SEC_KEY ] RSA-4096 Key exchange confirmed for UID:1000 (" + ms + "ms)",
                    "[ MEM_ALLOC] Reserved 512MB VRAM frame buffer at 0x" + hex,
                    "[ BIO_SYNC] Dermal node alignment active -> Latency: " + ms + "ms",
                    "[ KWIN_DRV] Rendering frame pipeline @ 144Hz [SYNC_OK]"
                ];
                var randLine = templates[Math.floor(Math.random() * templates.length)];
                terminalModel.append({ "line": randLine });
            }
            if (terminalModel.count > 25) {
                terminalModel.remove(0);
            }
            terminalView.positionViewAtEnd();
        }
    }

    Item {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 30
        width: 1250
        height: 600

        // ── ĽAVÝ PANEL (500px) ──
        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 500
            height: 480
            color: Qt.rgba(0, 0.05, 0.1, 0.85)
            border.color: root.cyanDim
            border.width: 1

            Rectangle { width: 10; height: 2; color: root.cyanPrimary; anchors.top: parent.top; anchors.left: parent.left }
            Rectangle { width: 2; height: 10; color: root.cyanPrimary; anchors.top: parent.top; anchors.left: parent.left }
            Rectangle { width: 10; height: 2; color: root.cyanPrimary; anchors.top: parent.top; anchors.right: parent.right }
            Rectangle { width: 2; height: 10; color: root.cyanPrimary; anchors.top: parent.top; anchors.right: parent.right }

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Row {
                    spacing: 10
                    Rectangle {
                        width: 4
                        height: 18
                        color: root.cyanPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "BIOMETRIC SCAN: ACTIVE"
                        color: root.cyanPrimary
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.5
                    }
                }

                Rectangle { width: parent.width; height: 1; color: root.cyanDim }

                Item {
                    width: parent.width
                    height: 210
                    clip: true
                    ListView {
                        id: terminalView
                        anchors.fill: parent
                        model: terminalModel
                        spacing: 4
                        delegate: Text {
                            text: model.line
                            color: root.cyanPrimary
                            font.family: "Monospace"
                            font.pixelSize: 10
                            opacity: 0.95
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: root.cyanDim }

                Column {
                    spacing: 6
                    width: parent.width
                    Repeater {
                        model: [
                            { t: "> KERNEL SUBSYSTEMS CORE........... [ READY ]", s: 20 },
                            { t: "> BIOMETRIC IDENTITY MATCH........ [ MATCHED ]", s: 50 },
                            { t: "> KDE PLASMA DESKTOP ENVIRONMENT... [ LOADING ]", s: 80 }
                        ]
                        Text {
                            text: modelData.t
                            color: root.cyanPrimary
                            font.family: "Monospace"
                            font.pixelSize: 10
                            opacity: root.visualProgress >= modelData.s ? 1.0 : 0.25
                        }
                    }
                }

                Item { width: 1; height: 10 }

                Rectangle {
                    width: parent.width
                    height: 28
                    color: Qt.rgba(0, 0.94, 1.0, 0.1)
                    border.color: root.cyanDim
                    Text {
                        anchors.centerIn: parent
                        text: "CLEARANCE LEVEL: OPERATOR 5 // UNRESTRICTED ACCESS"
                        color: root.cyanPrimary
                        font.family: "Monospace"
                        font.pixelSize: 10
                        font.bold: true
                    }
                }
            }
        }

        // ── PRAVÝ PANEL (DLAŇ + OVEROVANIE) ──
        Item {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 550
            height: 550

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.color: Qt.rgba(0, 0.94, 1.0, 0.2)
                border.width: 1

                Rectangle { width: 16; height: 2; color: root.cyanPrimary; anchors.top: parent.top; anchors.left: parent.left }
                Rectangle { width: 2; height: 16; color: root.cyanPrimary; anchors.top: parent.top; anchors.left: parent.left }
                Rectangle { width: 16; height: 2; color: root.cyanPrimary; anchors.bottom: parent.bottom; anchors.right: parent.right }
                Rectangle { width: 2; height: 16; color: root.cyanPrimary; anchors.bottom: parent.bottom; anchors.right: parent.right }
            }

            Image {
                id: hand
                source: "handprint.png"
                anchors.centerIn: parent
                width: 440
                height: 480
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Repeater {
                model: [
                    { rx: 0.19, ry: 0.36, label: "F-01" },
                    { rx: 0.33, ry: 0.23, label: "F-02" },
                    { rx: 0.47, ry: 0.20, label: "F-03" },
                    { rx: 0.65, ry: 0.25, label: "F-04" },
                    { rx: 0.80, ry: 0.53, label: "F-05" }
                ]
                Item {
                    id: fingerItem
                    x: hand.x + (hand.width * modelData.rx) - 12
                    y: hand.y + (hand.height * modelData.ry) - 12
                    width: 24
                    height: 24

                    property bool isVerified: false

                    Connections {
                        target: root
                        function onVerifyFinger(idx) {
                            if (idx === index) {
                                fingerItem.isVerified = true;
                                verifyAnim.start();
                            }
                        }
                    }

                    Rectangle {
                        id: ring
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"
                        border.color: fingerItem.isVerified ? root.alertGreen : root.alertRed
                        border.width: fingerItem.isVerified ? 2.5 : 1.5

                        Rectangle {
                            anchors.centerIn: parent
                            width: 4
                            height: 4
                            radius: 2
                            color: parent.border.color
                        }

                        SequentialAnimation on opacity {
                            running: !fingerItem.isVerified
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.1; to: 1.0; duration: 150 }
                            NumberAnimation { from: 1.0; to: 0.1; duration: 150 }
                        }

                        SequentialAnimation on opacity {
                            running: fingerItem.isVerified
                            loops: Animation.Infinite
                            NumberAnimation { from: 0.5; to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 1.0; to: 0.5; duration: 800; easing.type: Easing.InOutSine }
                        }

                        SequentialAnimation {
                            id: verifyAnim
                            NumberAnimation { target: ring; property: "width"; to: 36; duration: 150; easing.type: Easing.OutBack }
                            NumberAnimation { target: ring; property: "height"; to: 36; duration: 150; easing.type: Easing.OutBack }
                            NumberAnimation { target: ring; property: "radius"; to: 18; duration: 150; easing.type: Easing.OutBack }
                        }
                    }

                    Text {
                        x: 32
                        y: 2
                        text: fingerItem.isVerified ? "100%" : modelData.label
                        color: fingerItem.isVerified ? root.alertGreen : root.alertRed
                        font.pixelSize: fingerItem.isVerified ? 11 : 8
                        font.family: "Monospace"
                        font.bold: true

                        Behavior on font.pixelSize {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
            }

            // Laserový skener
            Rectangle {
                width: parent.width - 20
                height: 2
                x: 10
                color: root.cyanPrimary
                z: 10

                Rectangle {
                    width: parent.width
                    height: 20
                    anchors.bottom: parent.top
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 1.0; color: root.cyanGlow }
                    }
                }

                SequentialAnimation on y {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: hand.y + 30; to: hand.y + hand.height - 30; duration: 2400; easing.type: Easing.InOutSine }
                    NumberAnimation { to: hand.y + 30; duration: 2400; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // =========================================================
    // 5. SPODNÝ PROGRESS BAR + PERCENTÁ
    // =========================================================
    Item {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * 0.5
        height: 30

        Text {
            anchors.bottom: pbBg.top
            anchors.bottomMargin: 6
            anchors.right: pbBg.right
            text: "[ SYSTEM DECRYPT: " + Math.floor(root.visualProgress) + " % ]"
            color: root.cyanPrimary
            font.family: "Monospace"
            font.pixelSize: 11
            font.bold: true
        }

        Rectangle {
            id: pbBg
            anchors.bottom: parent.bottom
            width: parent.width
            height: 4
            color: Qt.rgba(0, 0.94, 1.0, 0.15)
            border.color: root.cyanDim

            Rectangle {
                height: parent.height
                width: parent.width * (root.visualProgress / 100)
                color: root.cyanPrimary

                Item {
                    anchors.fill: parent
                    clip: true
                    Rectangle {
                        width: 50
                        height: parent.height
                        color: "#ffffff"
                        opacity: 0.7
                        property real pos: 0
                        x: pos * parent.width - width

                        NumberAnimation on pos {
                            from: 0.0
                            to: 1.5
                            duration: 1200
                            loops: Animation.Infinite
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: "#ffffff"

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.3; to: 1.0; duration: 300 }
                        NumberAnimation { from: 1.0; to: 0.3; duration: 300 }
                    }
                }
            }
        }
    }
}
