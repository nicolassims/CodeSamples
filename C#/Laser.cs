/*
A script similar to the one I wrote when under the employ of Biogen. Contains a
    class that allows a laser pointer to be used in a virtual reality space.
*/

using UnityEngine;
using UnityEngine.UI;

/*
@class Laser: a class that can be attached to a remote controller to allow 
    selection of objects from afar
    
@var GameObject laserpointer: the object that this laser is attached to. 
@var LineRenderer lr: the component that draws the actual line
@var GameObject lastobject: The last object that the laser hovered over
@var GameObject selected: The last object that was clicked on
@var bool held: Whether the action1 button, which is used for selecting, is held
*/
public class Laser : MonoBehaviour {
    public GameObject laserpointer;//the object that this laser is attached to. 
    private LineRenderer lr; //The linerenderer that draws the laser
    private GameObject lastobject, selected; //The last object the laser hovered over, and the last object that was clicked on.
    private bool held = false; //The variable that tells whether the action1 button was held down last frame.

    void Start() {//Get the linerenderer component that will draw the laser.
        lr = GetComponent<LineRenderer>();
    }

    void Update() {// Update is called once per frame
    
        //If action1 is no longer held down, mark held as false.
        if (TVZUnity.TVZReturnButtonState("action1") <= 0.0f) {
            held = false;
        }
        
        //next two lines center, reset, and orient the laser to the controller
        laserpointer.transform.rotation = TVZUnity.GetWand0Orient();
        lr.SetPosition(0, TVZUnity.GetWand0Pos());//Set the base of the laser.
        
        //broadcast outward from the laser's base until you hit something.
        if (Physics.Raycast(TVZUnity.GetWand0Pos(), laserpointer.transform.forward, out RaycastHit hit)) {
            //keep track of the object you hit
            GameObject hitObject = hit.transform.gameObject;
            
            //if the last object hovered over exists, isn't selected, and isn't
            //      currently being hovered over...
            if (lastobject != null && lastobject != hitObject && lastobject != selected) {
                //Delete its outline.
                Destroy(lastobject.GetComponent<Outline>());
            }
            
            //if the object hit is not a button--i.e., it *is* a body part...
            if (hitObject.GetComponent<Button>() == null) {
                //and if the object the laser's hovering over has no outline...
                if (hitObject.GetComponent<Outline>() == null) {
                    //add one
                    hitObject.AddComponent<Outline>();
                }
                lastobject = hitObject;//mark the last object hovered over
            }
            
            //if the object hit has a collider--it's meant to be interacted with
            if (hit.collider) {
                
                //If mouse is clicked, or action1 button is pressed...
                if (Input.GetMouseButtonDown(0) || (TVZUnity.TVZReturnButtonState("action1") > 0.0f && !held)) {
                    
                    //mark this object as not just "hit," but selected
                    selected = hitObject;
                    
                    //mark the button as held, even if it's only just been 
                    //  pressed. This is to prevent dupe inputs on one press.
                    held = true;
                    
                    //if applicable, activate whatever button just clicked
                    if (hitObject.GetComponent<Button>()) {
                        hitObject.GetComponent<Button>().onClick.Invoke();
                    }
                    
                    //if applicable, activate whatever clickable just activated
                    if (hitObject.GetComponent<Clickable>() != null) {
                        hitObject.GetComponent<Clickable>().OnMouseDown();
                    }
                }
                
                //Set endpoint of laser on impact zone
                // we don't want the laser going through
                lr.SetPosition(1, hit.point);
            }
            
        //otherwise, if nothing was hit, but the cancel button was pressed...
        } else if ((Input.GetMouseButtonDown(1) || TVZUnity.TVZReturnButtonState("action2") > 0.0f) && selected != null) {
            //destroy the outline on the selected object, and make it unselected
            Destroy(selected.GetComponent<Outline>());
            selected = null;
            
        //finally, if nothing was hit, and no buttons were pressed...
        } else {
            //if last hovered-over object exists, and isn't selected...
            if (lastobject != null && lastobject != selected) {
                
                //destroy its outline and mark last hovered-over object as null
                Destroy(lastobject.GetComponent<Outline>());
                lastobject = null;
            }
            
            //Set endpoint off in far distance.
            lr.SetPosition(1, laserpointer.transform.forward * 500);
        }
    }
}
