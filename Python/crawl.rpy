label Crawl(map, startingy, startingx, knowledgemap):
    python:
        x = startingx
        y = startingy
        exit = False
    
    window hide
    show screen buttons()
    show screen mini_map_scr(map)
    
    while(exit == False):        
        python:
            knowledgemap[y][x] = 1
            if x != 0:
                knowledgemap[y][x - 1] = 1
                if y != len(knowledgemap) - 1:
                    knowledgemap[y + 1][x - 1] = 1
                if y != 0:
                    knowledgemap[y - 1][x - 1] = 1
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
            
            crawlMoveCommand = renpy.call_screen("buttons")
        
            if (crawlMoveCommand == 'F'):
                y -= 1
            elif (crawlMoveCommand == 'R'):
                x += 1
            elif (crawlMoveCommand == 'B'):
                y += 1
            elif (crawlMoveCommand == 'L'):
                x -= 1
        
        if (map[y][x] == -1):
            menu:
                "I'll stay a while longer...":
                    python:
                        if (crawlMoveCommand == 'F'):
                            y += 1
                        elif (crawlMoveCommand == 'R'):
                            x -= 1
                        elif (crawlMoveCommand == 'B'):
                            y -= 1
                        elif (crawlMoveCommand == 'L'):
                            x += 1 
                "Time to leave.":
                    $ exit = True
                    hide screen buttons
                    hide screen mini_map_scr
        elif (map[y][x] <= -2):
            call CrawlEvent(map.name, map[y][x])
            
    return
