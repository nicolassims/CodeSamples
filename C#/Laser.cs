using UnityEngine;
using UnityEngine.UI;

public class Laser : MonoBehaviour {
    public GameObject laserpointer;
    private LineRenderer lr; //The linerenderer that draws the laser
    private GameObject lastobject, selected; //The last object the laser hovered over, and the last object that was clicked on.
    private bool held = false; //The variable that tells whether the action1 button was held down last frame.

    void Start() {//Get the linerenderer component that will draw the laser.
        lr = GetComponent<LineRenderer>();
    }

    void Update() {// Update is called once per frame
        if (TVZUnity.TVZReturnButtonState("action1") <= 0.0f) {//If action1 is no longer held down, mark held as false.
            held = false;
        }
        laserpointer.transform.rotation = TVZUnity.GetWand0Orient();
        lr.SetPosition(0, TVZUnity.GetWand0Pos());//Set the base of the laser.
        if (Physics.Raycast(TVZUnity.GetWand0Pos(), laserpointer.transform.forward, out RaycastHit hit)) {
            GameObject hitObject = hit.transform.gameObject;
            if (lastobject != null && lastobject != hitObject && lastobject != selected) {//if the last object hovered over exists, isn't selected, and isn't currently being hovered over, delete its outline.
                Destroy(lastobject.GetComponent<Outline>());
            }
            if (hitObject.GetComponent<Button>() == null) {
                if (hitObject.GetComponent<Outline>() == null) {//If the object the laser's hovering over has no outline, add one.
                    hitObject.AddComponent<Outline>();
                }
                lastobject = hitObject;//mark the last object hovered over
            }
            if (hit.collider) {
                if (Input.GetMouseButtonDown(0) || (TVZUnity.TVZReturnButtonState("action1") > 0.0f && !held)) {//If mouse is clicked, or action1 button is pressed...
                    selected = hitObject;
                    held = true;//mark the button as held, even if it's only just been pressed. This is to prevent duplicate inputs on one press.
                    if (hitObject.GetComponent<Button>()) {
                        hitObject.GetComponent<Button>().onClick.Invoke();
                    }
                    if (hitObject.GetComponent<Clickable>() != null) {
                        hitObject.GetComponent<Clickable>().OnMouseDown();
                    }
                }
                lr.SetPosition(1, hit.point);//Set endpoint of laser on impact zone.
            }
        } else if ((Input.GetMouseButtonDown(1) || TVZUnity.TVZReturnButtonState("action2") > 0.0f) && selected != null) {
            Destroy(selected.GetComponent<Outline>());
            selected = null;
        } else {
            if (lastobject != null && lastobject != selected) {//if last hovered-over object exists, and isn't selected, destroy its outline and mark last hovered-over object as null
                Destroy(lastobject.GetComponent<Outline>());
                lastobject = null;
            }
            lr.SetPosition(1, laserpointer.transform.forward * 500);//Set endpoint off in far distance.
        }
    }
}
