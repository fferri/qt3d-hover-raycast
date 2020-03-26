import QtQuick 2.14
import QtQuick.Window 2.14 as QtQuick
import QtQuick.Scene3D 2.0
import Qt3D.Core 2.12
import Qt3D.Render 2.12
import Qt3D.Input 2.12
import Qt3D.Extras 2.12

QtQuick.Window {
    visible: true
    width: 640
    height: 480

    Scene3D {
        anchors.fill: parent
        aspects: ["render", "logic", "input"]
        hoverEnabled: true
        Entity {
            components: [
                RenderSettings {
                    activeFrameGraph: ForwardRenderer {
                        clearColor: Qt.rgba(0.8, 0.8, 0.8, 1)
                        camera: mainCamera
                    }
                    pickingSettings.pickResultMode: PickingSettings.NearestPick//PickingSettings.AllPicks
                    pickingSettings.pickMethod: PickingSettings.PrimitivePicking
                    pickingSettings.faceOrientationPickingMode: PickingSettings.FrontFace
                },
                InputSettings {},
                ScreenRayCaster {
                    id: rayCaster
                    layers: [skipRayCaster]; filterMode: ScreenRayCaster.DiscardAnyMatchingLayers
                    onHitsChanged: {
                        mesh.enabled = false
                        for(var hit of hits) {
                            mesh.enabled = true
                            t.translation = Qt.vector3d(hit.worldIntersection.x, hit.worldIntersection.y, hit.worldIntersection.z)
                            break
                        }
                    }
                }
            ]
            Layer {
                id: skipRayCaster
            }
            Camera {
                id: mainCamera
                projectionType: CameraLens.PerspectiveProjection
                fieldOfView: 45
                aspectRatio: 16/9
                nearPlane: 0.1
                farPlane: 1000
                upVector: Qt.vector3d(0, 0, 1)
                position: Qt.vector3d(0, 10, 3)
                viewCenter: Qt.vector3d(0, 0, 0)
            }
            OrbitCameraController {
                camera: mainCamera
            }
            NodeInstantiator {
                model: 30
                delegate: Entity {
                    objectName: "Cuboid#" + index
                    components: [
                        CuboidMesh {
                            property real size: Math.random() * 3 + 0.1
                            xExtent: size; yExtent: size; zExtent: size
                        },
                        Transform {
                            rotationX: Math.random() * 90
                            rotationY: Math.random() * 90
                            rotationZ: Math.random() * 90
                            translation.x: (Math.random() - 0.5) * 8
                            translation.y: (Math.random() - 0.5) * 8
                            translation.z: (Math.random() - 0.5) * 8
                        },
                        PhongMaterial {
                            diffuse: Qt.rgba(0.8, 0.8, 1, 1)
                        }
                    ]
                }
            }
            MouseDevice {
                id: mouseDevice
            }
            MouseHandler {
                sourceDevice: mouseDevice
                onPositionChanged: rayCaster.trigger(Qt.point(mouse.x, mouse.y))
            }
            Entity {
                id: sphere
                SphereMesh {
                    id: mesh
                    radius: 0.1
                }
                Transform {
                    id: t
                }
                PhongMaterial {
                    id: mat
                    ambient: Qt.rgba(0.8, 1, 0.2, 1)
                }
                components: [mesh, t, mat, skipRayCaster]
            }
        }
    }
}
