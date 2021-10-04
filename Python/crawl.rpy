'''
A script written for an unfinished project. Runs a "dungeon crawling" system where players can move around on a map, interact with nodes, and be blocked by walls. Uses a system whereby it can be fed text files and create maps of them.

@func Crawl(int[][], int, int, int[][]) -> None: A function that takes in a 
    completed map of an area, a starting x and y location, and a map of what the
    player knows the area to be
@arg map: A two-dimensional array that represents an area. A 1 represents a 
    solid wall, and a 0 represents open space. Negative numbers are events.
@arg startingy: The y-coordinate the player should load into
@arg startingx: The x-coordinate the player should load into
@ark knowledgemap: A two-dimensional array that represents how much of an area a
    player has explored.

Maps are created in the following format, or by loading in a text file:
guerroforest = []
guerroforest.name = "guerroforest"
guerroforest.append([1, -1, 1, 1, -1, 1, 1, 1])
guerroforest.append([1, 0, 1, 0, 0, 1, 1, 1])
guerroforest.append([1, 0, 1, 0, 1, 1, 1, 1])
guerroforest.append([1, 0, 0, 0, 1, -2, -3, 1])
guerroforest.append([1, 1, 1, 0, 1, 1, 0, 1])
guerroforest.append([1, 1, 0, 0, 0, 1, 0, 1])
guerroforest.append([1, 1, 0, 0, 0, 0, 0, 1])
guerroforest.append([1, 1, 1, 1, 1, 1, 1, 1])
'''

label Crawl(map, startingy, startingx, knowledgemap):
    python:
        x = startingx
        y = startingy
        exit = False
    
    window hide#Ren'Py function that hides the built-in gui
    show screen buttons()#Custom func that will show the nav arrows/enable wasd
    show screen mini_map_scr(map)#draws the mini map
    
    while(exit == False):#keep the loop running until a player navigates out     
        python:
            #this section just marks your spot, and the eight spots around you,
            #   as "known" in the knowledge map. Will not attempt to mark
            #   exterior walls as known. First section is fully commented, but
            #   all sections run similarly
            knowledgemap[y][x] = 1#mark current spot as known
            if x != 0:#if you aren't on the far left...
                knowledgemap[y][x - 1] = 1#mark the spot to your left known
                if y != len(knowledgemap) - 1:#if you're not on the bottom...
                    knowledgemap[y + 1][x - 1] = 1#mark your bottom-left known
                if y != 0:#if you're not on the top...
                    knowledgemap[y - 1][x - 1] = 1#mark your top-left known
            if y != 0:
                knowledgemap[y - 1][x] = 1
                if x != len(knowledgemap[0]) - 1:
                    knowledgemap[y - 1][x + 1] = 1
            if y != len(knowledgemap) - 1:
                knowledgemap[y + 1][x] = 1
            if x != len(knowledgemap[0]) - 1:
                knowledgemap[y][x + 1] = 1
                if y != len(knowledgemap) - 1:          
                    knowledgemap[y + 1][x + 1] = 1
            
            crawlMoveCommand = renpy.call_screen("buttons")#wait for movement input
            #worth mentioning that the "buttons" screen will not allow you to 
            #   press a button that would cause you to move into a wall
        
            if (crawlMoveCommand == 'F'):#Forward. Represented by ↑ character
                y -= 1
            elif (crawlMoveCommand == 'R'):#Right. Represented by → character
                x += 1
            elif (crawlMoveCommand == 'B'):#Backward. Represented by ↓ character
                y += 1
            elif (crawlMoveCommand == 'L'):#Left. Represented by ← character
                x -= 1
        
        if (map[y][x] == -1):#entering a cell with a key code of "-1", an exit
            menu:#Present these two options
                "I'll stay a while longer...":
                    python:#reverse most recent command, to send you back a cell
                        if (crawlMoveCommand == 'F'):
                            y += 1
                        elif (crawlMoveCommand == 'R'):
                            x -= 1
                        elif (crawlMoveCommand == 'B'):
                            y -= 1
                        elif (crawlMoveCommand == 'L'):
                            x += 1 
                "Time to leave.":
                    $ exit = True#set exit condition for while loop to "true"
                    hide screen buttons
                    hide screen mini_map_scr
        #if this cell has any other kind of special event...
        elif (map[y][x] <= -2):
            #then send it to the callEvent script, which will handle it.
            call CrawlEvent(map.name, map[y][x])
            
    return
