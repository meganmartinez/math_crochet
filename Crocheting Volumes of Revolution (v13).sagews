︠9186cacf-d279-49d5-811f-bebc4edc3814s︠
#################################################
##****##EVALUATE THIS BLOCK OF CODE FIRST##****##
#################################################

#f(x) is a positive function between input values a and b
#a is the lower x-bound of the solid
#b is the upper x-bound of the solid
#S gives the number of stitches per 4"
#R gives the number of rows per 4"
#scale is the measurement of one unit in inches

##This will find the x-values for where the rows should occur in our pattern. The output is a list containing two things: The list of coordinates along the curve and the list of only the x-values.
def Landmarks(f,a,b,S,R,scale):
    #We start by finding the locations of our local mins and maxes. We note that technically discontinuties count, but we are not allowing that in our program. We use a guess and check method rather than the built-in commands to make this work for the most functions possible.
    last_three_list = [0,f(a),f(a+0.01)] #this is a list that is continually updated and will be looking for a peak or valley. If the middle entry is the largest or smallest, we will record it at the location of a local min or max.
    t = a + 2*0.01
    Imp_Landmarks = [a] #start with "a" in our list; these will be the endpoints, peaks, and valleys
    while t <= b: #This while loop will run until t gets to our endpoint
        last_three_list = last_three_list[1:3] + [f(t)] #Here we update our three entries to shift everything down by x=0.01
        if max(last_three_list)==last_three_list[1]: #We check if the middle value is a local max, if so, we add it to the landmarks
            Imp_Landmarks = Imp_Landmarks + [t-0.01]
        elif min(last_three_list)==last_three_list[1]: #We check if the middle value is a local min, if so, we add it to the landmarks
            Imp_Landmarks = Imp_Landmarks + [t-0.01]
        t = t + 0.01
    Imp_Landmarks = Imp_Landmarks + [b] #We end the endpoint, b, to our landmarks. Now we have the important rows we need to hit. We fill in from here by measuring the arclength between each consecutive Imp_Landmark to determine how many rows should be filled in.

    #Note that if the local minima or maxima are withing 0.5 of a row, we will end up with some distortion. In this case, we will output a warning.
    l = len(Imp_Landmarks)
    Differences = [scale*R/4*numerical_integral(sqrt(1+(diff(f,x))^2),Imp_Landmarks[i-1],Imp_Landmarks[i])[0] for i in [1..l-1]]
    #If a or b is really close to a peak or valley, we just keep the peak or valley.
    if Differences[0]<0.5 and len(Differences)>1:
        Imp_Landmarks = Imp_Landmarks[1:]
    if Differences[-1]<0.5 and len(Differences)>1:
        Imp_Landmarks = Imp_Landmarks[0:-1]
    Differences = Differences[1:-1]
    if Differences != []:
        Too_close = 0
        for elem in Differences:
            if elem<0.5:
                Too_close = 1
        if Too_close == 1:
            print("Local extrema for your chosen function are very close together; it is recommended that you increase scale to preserve the accurace of your model")

#Here we find the landmarks by evenly dividing arclength between each local extrema in the Imp_Landmarks list.
    l = len(Imp_Landmarks) #number of landmarks
    xLandmarks = [a] #This is the list where we will record our x-values
    for i in [0..l-2]:
        a2 = Imp_Landmarks[i] #The first peak/valley location
        b2 = Imp_Landmarks[i+1] #The next peak/valley location
        ArcLength = scale*R/4*numerical_integral(sqrt(1+(diff(f,x))^2),a2,b2)[0]
        Total_Rows = round(ArcLength) #number of rows needed after a2; a2 is actually already in xLandmarks
        if Total_Rows > 1:
            #Ideally, we will distribute our rows as evenly as possible, so we will take the actual arclength between our landmarks and
            #divide by the number of intermediate rows needed.
            Length = ArcLength/(Total_Rows)
            var('d')
            for row in [1..Total_Rows]: #We know how many rows fit between our landmarks (counting the landmark b2) so we know how
                #many times this loop will run.
                done = 0 #"done" is a variable that will be switched to 1 when we find the location of our next landmark, hence pushing us out
                #of a while loop to move on to the next landmark
                d = 0.01 #"d" is a difference variable. We will use it as a variable that is incrememnted by 0.01 to locate the x-value
                #for our next circumference measurement/row
                PrevArcLength = 0
                while done == 0:
                    ArcLength = numerical_integral(sqrt(1+(diff(f,x))^2),a2,a2+d)[0]
                    if scale*PrevArcLength*R/4 - row*Length <= 0 and scale*ArcLength*R/4 - row*Length >= 0: #we want to be about row*Length arclength in at this point.
                        #So we are figuring out when we reach that point.
                        if (scale*ArcLength*R/4-row*Length)-abs(scale*PrevArcLength*R/4-row*Length)<=0: #here we are just trying to figure out whether ArcLength
                            #(which is arclength from a to a+d) or PrevArcLength (which is arclength from a to a+d-0.01) is the closer approximation for our row.
                            #If this measurement is negative, it means the the ArcLength measurement is closer, so we should use that. The variable c is the x-value
                            #that we will actually use to take the circumference measurement.
                            c = d
                        else: #if (scale*ArcLength*R/4-row+1)-abs(scale*PrevArcLength*R/4-row+1)<=0 is NOT TRUE, then PrevArcLength is actually the better estimate.
                            #So we set c equal to the PREVIOUS d value (which is 0.01 smaller).
                            c = d-0.01
                        xLandmarks = xLandmarks + [a2+c]
                        done = 1
                    else: #This case occurs if our scale*PrevArcLength*R/4 - row + 1 and our scale*ArcLength*R/4 - row + 1 did not fall on either side of 0.
                        #We increment d by 0.01 and run the loop again. We also set the PrevArcLength to be the current ArcLength.
                        d = d + .01
                        PrevArcLength = ArcLength
        else:
            xLandmarks = xLandmarks + [Imp_Landmarks[i+1]]
    Landmarks = [(x, f(x)) for x in xLandmarks]
    return [Landmarks,xLandmarks]

#This program will take the list of x-coordinates which give the outline of the shape xLandmarks, the (x,y) coordinates Landmarks, the function f, and the endpoints a,b and print relevant warnings for when our code will not produce a good pattern.
####WARNING SECTION: This section will identify possible problems that will come from the particular function/scale/gauge combination. It will suggest alternatives to make a shape that is more accurate####
def Warnings(xLandmarks,Landmarks,f,a,b,S,R,scale):
    ##Increase or Decrease too quickly.
    l = len(Landmarks)
    smallest = min([round(scale*S/4*2*pi*Landmarks[i][1]) for i in [1..l-2]]) #This is the smallest number of stitches in an interior row.
    if 0<=round(scale*S/4*2*pi*Landmarks[-1][1])<=3: #If we end with zero circumference, take out of landmarks so we don't divide by zero. We also take out that landmark if it is less than three, because our program will just have the crochet close off the shape.
        Landmarks = Landmarks[:l-1]
        l = l-1
    if 0<=round(scale*S/4*2*pi*Landmarks[0][1])<=3: #If we start with zero circumference, take out of landmarks so we don't divide by zero. We also take out that landmark if it is less than three, because our program will just have the crochet close off the shape.
        Landmarks = Landmarks[1:]
        l = l-1
    if smallest == 0:
        print("Your chosen function requires 0 stitches on an interior row; either choose a new function, or shift this function up.")
    else:
        Ratios = [round(scale*S/4*2*pi*Landmarks[i+1][1])/round(scale*S/4*2*pi*Landmarks[i][1]) for i in [0..l-2]] #This gives us the stitch ratios between consecutive rows. If more than 2, increases too much. If less than 1/2, decreases too much
        #with these next to if statements we remove the first and last ratios if the shape starts or ends with zero circumference. This isn't a concern since we have a way to do this.
        Too_Fast = 0 #This will be set to 1 if a warning needs to be printed
        Max_Ratio = max(Ratios)
        max_pos = Ratios.index(Max_Ratio) #This is the index of the largest ratio
        Min_Ratio = min(Ratios)
        min_pos = Ratios.index(Min_Ratio) #This is the index of the smallest ratio
        shift = 0
        new_scale = scale
        f_prime = diff(f,x)
        if Max_Ratio > 2: #This activates if we increase too quickly
            shift = f(Landmarks[max_pos+1][0])-2*f(Landmarks[max_pos][0]) #This is the quick calculation to figure out what shift factor would rid us of the problem;
            #because of rounding, this might not be big enough; we do need to test it to see if it needs increaseing, which happens here:
            while round(scale*S/4*2*pi*(Landmarks[max_pos+1][1]+shift))/round(scale*S/4*2*pi*(Landmarks[max_pos][1]+shift))>2:
                shift = shift + 0.01
            Too_Fast = 1
        elif Min_Ratio < 1/2: #This activates if we decrease too quickly
            shift = max(shift,f(Landmarks[min_pos][0])-2*f(Landmarks[min_pos+1][0])) #This is the shift we calculate; we use the min to account for if there were increases that were too big. If not, I had previously set shift to 0, so this will be fine; because of rounding, this might not be big enough; we do need to test it to see if it needs increaseing, which happens here:
            while round(scale*S/4*2*pi*(Landmarks[min_pos+1][1]+shift))/round(scale*S/4*2*pi*(Landmarks[min_pos][1]+shift))<.5:
                shift = shift + 0.01
            Too_Fast = 1
        if Too_Fast == 1:
            print("Your inputs require an increase or decrease in stitches that is too rapid. The easiest way to fix this is to shift your function up by n =",n(shift,digits = 7),"so your new function is f(x) + n. You can also try adjusting your scale value.")

###DISTANCE MEASURE BETWEEN ROWS####
#This program will take two lists of ratios and figure out the distance between them
#The way of measuring distance will be to take a ratio, find the closest ratio in the other list. Then find the minimum of all these distances. Additionally, we will measure the average of all these distances. So, in the case of a tie, we can pick the larger average for our choice.
def Distance2(Ratios_Old,Ratios_New): #Ratios_Old is the older set of ratios, Ratios_New is the newer set of ratios
    distances = [] #this is where we will record all the distances between the closest ratios
    for ratio_new in Ratios_New:
        ratio_more_than_half = 0
        ratio_distances = [] #This will measure all the distances between the chosen new ratio and all the old ratios
        for ratio_old in Ratios_Old:
            ratio_distances = ratio_distances + [min(abs(ratio_old-ratio_new),1-abs(ratio_old-ratio_new))]
        distances = distances + [min(ratio_distances)]
    return [min(distances), sum(distances)/len(distances)] #we return [smallest distance, average distance]

def inc_dec_pos(prevstitches,stitches,prevratios): #This program will figure out where to place increases and decreases and will produce a list with those locations. prevstitches is the number of stitches in the previous row, stitches is the number of stitches in the current row, and prevratios is the list of ratios for the position of increases or decreases in the previous row.
    difference = stitches - prevstitches
    if difference==0: #If there is no change in stitches, then we don't need increases or decreases
        desired_positions = []
    else:
        stitch_count = min(stitches,prevstitches) #This is the number of instructions needed in the row
        repeat_length = floor(stitch_count/abs(difference)) #This gives us the spacing between repeated increases/decreases
        remainder = stitch_count - abs(difference)*repeat_length #These are the remainder stitches that will be placed at the beginning/end in some configuration
        desired_positions = [repeat_length*j+1 for j in [0..abs(difference)-1]] #we just want to start this off non-empty
        prevdistance = 0
        prevmean = 0
        for i in [1..(remainder+repeat_length)]: #We run this look to check the result of shifting the increases and decreases around the row; ranging from having an inc/dec as the first stitch all the way to having an inc/dec as the last stitch.
            positions = [repeat_length*j + i for j in [0..abs(difference)-1]]
            ratios = [elem/stitch_count for elem in positions]
            newdistance = Distance2(prevratios,ratios)[0]
            newmean = Distance2(prevratios,ratios)[1]
            if newdistance > prevdistance:
                prevdistance = newdistance
                prevmean = newmean
                desired_positions = positions
            elif newdistance == prevdistance:
                 if newmean > prevmean:
                    prevdistance = newdistance
                    prevmean = newmean
                    desired_positions = positions
    return desired_positions

#This program will take a list of inc/dec positions, number of stitches in the previous row, number of stitches in the current row, and current row number. Then it will produce the instructions for this row.
##A note on the inc_dec_list: when there are decreases, the increases and decreases are the positions amount the new number of stitches (2 stitches become 1 in new row)
###when there are increases, the increases and decreases are the positions among the old number of stitches (1 stitch in old row becomes 2 in new row)
def row_instructions(inc_dec_list,prevstitches,stitches,row):
    instructions = ''
    instructions += str("Row ")
    instructions += str(row)
    instructions += str(":")
    if inc_dec_list == []: #If there are no increases or decreases
        instructions += str(" Sc")
        instructions += str(stitches)
        instructions += str(". (")
        instructions += str(stitches)
        instructions += str(" stitches)")
    else: #If there are increases and decreases
        k = len(inc_dec_list)
        sc_list = [inc_dec_list[0]-1] #this list gives all the single crochet amounts that need to appear
        sc_list = sc_list + [inc_dec_list[i]-inc_dec_list[i-1]-1 for i in [1..k-1]]
        sc_list = sc_list + [min(prevstitches,stitches)-inc_dec_list[k-1]]
        i = 0
        while i < k:
            j = i
            while sc_list[i]==sc_list[j] and j < k: #We want to figure out how many times we need to repeat an instruction; we start j at i,
                #then increment larger as long as the Sc stretches are the same. Once they are different, we stop and add the relevant instructions to our row.
                j = j+1
            if i>0:
                instructions += str(",") #If this isn't the first instruction in the row, we need a comma.
            if prevstitches < stitches: #If we need increases
                if sc_list[i]==0: #When there are no Sc stitches, just increases
                    if i == j-1: #If only one repeat needed
                        instructions += str(" Inc")
                    else: #Multiple repeats needed
                        instructions += str(" *Inc* (")
                        instructions += str(j-i)
                        instructions += str(" times)")
                else: #There are Sc stitches
                    if i == j-1: #When there is only one repeat needed
                        instructions += str(" Sc")
                        instructions += str(sc_list[i])
                        instructions += str(", Inc")
                    else: #multiple repeats needed
                        instructions += str(" *Sc")
                        instructions += str(sc_list[i])
                        instructions += str(", Inc* (")
                        instructions += str(j-i)
                        instructions += str(" times)")
            else: #If we need decreases
                if sc_list[i]==0: #When there are no Sc stitches, just decreases
                    if i == j-1: #If only one repeat needed
                        instructions += str(" Dec")
                    else: #Multiple repeats needed
                        instructions += str(" *Dec* (")
                        instructions += str(j-i)
                        instructions += str(" times)")
                else: #There are Sc stitches
                    if i == j-1: #When there is only one repeat needed
                        instructions += str(" Sc")
                        instructions += str(sc_list[i])
                        instructions += str(", Dec")
                    else: #multiple repeats needed
                        instructions += str(" *Sc")
                        instructions += str(sc_list[i])
                        instructions += str(", Dec* (")
                        instructions += str(j-i)
                        instructions += str(" times)")
            i = j #this goes back to the while loop = we want to figure out how many of the Sc measures we have already written instructions for and start from there.
        if sc_list[-1] != 0: #Sometimes there will be a zero at the end of our list. In this case, we won't need these last instructions.
            instructions += str(", Sc")
            instructions += str(sc_list[-1])
        instructions += str(". (") #This just gives how many stitches we have after completing this row.
        instructions += str(stitches)
        instructions += str(" stitches)")
    return instructions

#This is the program that we will call to create our pattern. All the input variables are defined on the top.
def Pattern(f,a,b,S,R,scale):
    #This will tell the user if there isn't enough space between a and b for even one row.
    if b-a<=4/(R*scale):
        print("Your a and b values are too close together - either increase your scale or choose new a and b values")
    #Before we even start, we are going to check that the function f doesn't reach 0 internally. We don't care if the endpoints are roots, so we will check for roots in the interior of a and b - we can do this by figuring our how big a row is in the graph and taking that off the top and bottom of the interval.
    else:
        try:
            find_root(f,a+4/(R*scale),b-4/(R*scale))
            print("Your function has at least one root between a and b. Ensure that your function is strictly positive on (a,b).")
        except RuntimeError:
            LandmarkList = Landmarks(f,a,b,S,R,scale)
            L = LandmarkList[0]
            xL = LandmarkList[1]
            Warnings(xL,L,f,a,b,S,R,scale)
            stitches = round(scale*(L[0][1]*2*pi)/(4/S)) #this measures the number of stitches we start with
            prevstitches = stitches
            start = 0 #this tells us if we will start with a closed shape
            if 0<=stitches<=3: #Here is the loop if we start with less than or equal to 3 stitches
                start = 1
                instructions = ''
                instructions += str("Row 0: Chain 2.")
                print(instructions)
                stitches = round(scale*(L[1][1]*2*pi)*(S/4))
                instructions = ''
                instructions += str("Row 1: Work ")
                instructions += str(stitches)
                instructions += str(" Sc in 2nd chain from hook. Place marker for beginning of round; move marker up as each round is completed.")
                print(instructions)
                instructions = ''
                prevstitches = stitches
                row = 2
            else:
                instructions = '' #"instructions" is a string that will be the actual crocheting instructions. These are assembled throughout the entire code
                instructions += str("Row 0: Chain ")
                instructions += str(stitches)
                instructions += str(". Join work and Sc")
                instructions += str(stitches)
                instructions += str(". Place marker for beginning of round; move marker up as each round is completed.")
                print(instructions)
                instructions = ''
                row = 1 #now we increment row to be 1, since we have already made the Row 0 instruction
            prevratios = [0] #We need this list to start with something, so I'm just defaulting it with a zero
            l = len(L)
            close = 0 #When this is 0 the shape is not closed off
            if 0<=round(scale*S/4*2*pi*L[-1][1])<=3: #If we are going to end with a zero stitch row (or very close to it), we remove the last 
                #landmark and set close to 1
                L = L[:l-1]
                close = 1
            r=row
            for coordinate in L[row:]:
                x1 = coordinate[0]
                y1 = coordinate[1]
                if start==1 and close==1 and coordinate == L[-2]: #Before we close off the shape, we have the option to stuff it.
                    instructions += str("If you want a stuffed shape, firmly stuff your object with fiber fill.")
                    print(instructions)
                    instructions = ''
                stitches = round(scale*(y1*2*pi)*(S/4))
                inc_dec_list = inc_dec_pos(prevstitches,stitches,prevratios)
                if inc_dec_list != []:
                    prevratios = [elem/min(prevstitches,stitches) for elem in inc_dec_list] #Now we update the new ratios if there are increases/decreases
                print(row_instructions(inc_dec_list,prevstitches,stitches,row)) #This produces the instructions for the row and also decides where increases/decreases should be
                prevstitches = stitches
                row = row + 1
            if close == 0:
                instructions = ''
                instructions = str("Tie off.")
            elif close == 1 and start == 1:
                instructions = ''
                instructions = str("Before tying off, top off the stuffing, if using. To close the surface, cut the yarn leaving a generous tail, thread a tapestry needle with the tail, and weave through the stitches in the last row. Pull to tighten and tie off.")
            else:
                instructions = ''
                instructions = str("To close the surface, cut the yarn leaving a generous tail, thread a tapestry needle with the tail, and weave through the stitches in the last row. Pull to tighten and tie off.")
            print(instructions)
            print("Row measurements were taken at the following coordinates:",L)
︡b01bc0f3-804e-438f-8d50-7bae2899887a︡{"done":true}
︠57ff0874-937d-4aab-b505-5e4fa8d4a3e8s︠
f(x)=x^3+2*x^2-2*x+4
a=-3
b=1
S=22
R=25
scale=0.18
Pattern(f,a,b,S,R,scale)
︡1df53fd8-4ea3-4d95-aad9-2f56e204442e︡{"stdout":"Row 0: Chain 6. Join work and Sc6. Place marker for beginning of round; move marker up as each round is completed."}︡{"stdout":"\nRow 1: *Inc* (6 times). (12 stitches)\nRow 2: Inc, *Sc1, Inc* (5 times), Sc1. (18 stitches)\nRow 3: *Sc2, Inc* (6 times). (24 stitches)\nRow 4: Sc1, Inc, *Sc3, Inc* (4 times), Sc6. (29 stitches)\nRow 5: Sc6, Inc, *Sc3, Inc* (5 times), Sc2. (35 stitches)\nRow 6: Inc, *Sc4, Inc* (5 times), Sc9. (41 stitches)\nRow 7: Sc3, Inc, *Sc5, Inc* (5 times), Sc7. (47 stitches)\nRow 8: Sc12, Inc, *Sc10, Inc* (3 times), Sc1. (51 stitches)\nRow 9: Sc6, Dec, *Sc10, Dec* (3 times), Sc7. (47 stitches)\nRow 10: Sc4, Dec, *Sc7, Dec* (4 times), Sc5. (42 stitches)\nRow 11: Dec, *Sc6, Dec* (4 times), Sc8. (37 stitches)\nRow 12: Sc3, Dec, *Sc5, Dec* (4 times), Sc4. (32 stitches)\nRow 13: Dec, *Sc4, Dec* (4 times), Sc6. (27 stitches)\nRow 14: Sc2, Dec, *Sc3, Dec* (4 times), Sc3. (22 stitches)\nRow 15: Sc6, Inc, *Sc4, Inc* (3 times). (26 stitches)\nRow 16: Sc1, Inc, *Sc4, Inc* (4 times), Sc4. (31 stitches)\nTie off.\nRow measurements were taken at the following coordinates: [(-3, 1), (-2.93000000000000, 1.87604300000000), (-2.84000000000000, 2.90489600000000), (-2.75000000000000, 3.82812500000000), (-2.65000000000000, 4.73537500000000), (-2.53000000000000, 5.66752300000000), (-2.38000000000000, 6.60752800000000), (-2.18000000000000, 7.50456800000000), (-1.72000000000000, 8.26835200000000), (-1.22000000000002, 7.60095200000005), (-0.920000000000020, 6.75411200000006), (-0.670000000000020, 5.93703700000007), (-0.410000000000020, 5.08727900000006), (-0.120000000000019, 4.26707200000005), (0.389999999999978, 3.58351900000000), (0.809999999999981, 4.22364099999994), (0.999999999999981, 4.99999999999991)]\n"}︡{"done":true}
︠fa496494-007f-4b99-9c22-1222477ee750s︠
f(x)=0.8*((x-2)^2+2)^(0.5)
a=0
b=4
S=18
R=22
scale=1
Pattern(f,a,b,S,R,scale)
︡7e7b8bc6-e693-48e5-bdb8-97849c19e084︡{"stdout":"Row 0: Chain 55. Join work and Sc55. Place marker for beginning of round; move marker up as each round is completed."}︡{"stdout":"\nRow 1: Sc12, Dec, Sc25, Dec, Sc14. (53 stitches)\nRow 2: Sc16, Dec, *Sc15, Dec* (2 times), Sc1. (50 stitches)\nRow 3: Sc7, Dec, *Sc14, Dec* (2 times), Sc9. (47 stitches)\nRow 4: Sc3, Dec, Sc21, Dec, Sc19. (45 stitches)\nRow 5: *Sc13, Dec* (3 times). (42 stitches)\nRow 6: Sc9, Dec, Sc19, Dec, Sc10. (40 stitches)\nRow 7: *Sc18, Dec* (2 times). (38 stitches)\nRow 8: Sc8, Dec, Sc17, Dec, Sc9. (36 stitches)\nRow 9: *Sc16, Dec* (2 times). (34 stitches)\nRow 10: Sc7, Dec, Sc25. (33 stitches)\nRow 11: Sc23, Dec, Sc8. (32 stitches)\nRow 12: Sc32. (32 stitches)\nRow 13: Sc32. (32 stitches)\nRow 14: Sc7, Inc, Sc24. (33 stitches)\nRow 15: Sc24, Inc, Sc8. (34 stitches)\nRow 16: *Sc16, Inc* (2 times). (36 stitches)\nRow 17: Sc8, Inc, Sc17, Inc, Sc9. (38 stitches)\nRow 18: *Sc18, Inc* (2 times). (40 stitches)\nRow 19: Sc9, Inc, Sc19, Inc, Sc10. (42 stitches)\nRow 20: Sc6, Inc, *Sc13, Inc* (2 times), Sc7. (45 stitches)\nRow 21: Sc10, Inc, Sc21, Inc, Sc12. (47 stitches)\nRow 22: *Sc14, Inc* (3 times), Sc2. (50 stitches)\nRow 23: Sc7, Inc, *Sc15, Inc* (2 times), Sc10. (53 stitches)\nRow 24: Sc3, Inc, Sc25, Inc, Sc23. (55 stitches)\nTie off.\nRow measurements were taken at the following coordinates: [(0, 1.95959179422654), (0.150000000000000, 1.86290096355120), (0.310000000000000, 1.76292484241388), (0.470000000000000, 1.66678612905195), (0.620000000000000, 1.58076437206815), (0.780000000000000, 1.49418071196224), (0.950000000000001, 1.40911319630468), (1.12000000000000, 1.33252242007405), (1.29000000000000, 1.26594786622515), (1.46000000000000, 1.21104252609064), (1.64000000000000, 1.16745192620510), (1.82000000000000, 1.14049813678059), (2.00000000000000, 1.13137084989848), (2.18000000000000, 1.14049813678059), (2.36000000000000, 1.16745192620510), (2.54000000000000, 1.21104252609064), (2.71000000000000, 1.26594786622515), (2.88000000000000, 1.33252242007405), (3.05000000000000, 1.40911319630468), (3.22000000000000, 1.49418071196225), (3.38000000000000, 1.58076437206815), (3.53000000000000, 1.66678612905196), (3.69000000000000, 1.76292484241388), (3.85000000000000, 1.86290096355120), (4.00000000000000, 1.95959179422654)]\n"}︡{"done":true}
︠7781c8b9-ae16-4238-aad2-f925c449c7c2s︠
f(x)=4-x^2
a=-2
b=2
S=22
R=25
scale=0.8
Pattern(f,a,b,S,R,scale)
︡fc23d3a0-c634-431e-89f3-f07e56399168︡{"stdout":"Your inputs require an increase or decrease in stitches that is too rapid. The easiest way to fix this is to shift your function up by n ="}︡{"stdout":" 0.005000000 so your new function is f(x) + n. You can also try adjusting your scale value.\nRow 0: Chain 2.\nRow 1: Work 5 Sc in 2nd chain from hook. Place marker for beginning of round; move marker up as each round is completed.\nRow 2: Sc1, Inc, *Sc-1, Inc* (5 times), Sc3. (11 stitches)\nRow 3: Sc2, Inc, *Sc1, Inc* (4 times). (16 stitches)\nRow 4: Inc, *Sc1, Inc* (5 times), Sc5. (22 stitches)\nRow 5: Sc4, Inc, *Sc3, Inc* (4 times), Sc1. (27 stitches)\nRow 6: Sc1, Inc, *Sc3, Inc* (5 times), Sc5. (33 stitches)\nRow 7: Sc7, Inc, *Sc5, Inc* (4 times), Sc1. (38 stitches)\nRow 8: Sc5, Inc, *Sc6, Inc* (4 times), Sc4. (43 stitches)\nRow 9: Sc10, Inc, *Sc7, Inc* (4 times). (48 stitches)\nRow 10: Sc7, Inc, *Sc8, Inc* (4 times), Sc4. (53 stitches)\nRow 11: Sc1, Inc, *Sc7, Inc* (5 times), Sc11. (59 stitches)\nRow 12: Sc7, Inc, *Sc10, Inc* (4 times), Sc7. (64 stitches)\nRow 13: Sc14, Inc, *Sc11, Inc* (4 times), Sc1. (69 stitches)\nRow 14: Sc2, Inc, *Sc10, Inc* (5 times), Sc11. (75 stitches)\nRow 15: Sc13, Inc, *Sc14, Inc* (4 times), Sc1. (80 stitches)\nRow 16: Sc6, Inc, *Sc15, Inc* (4 times), Sc9. (85 stitches)\nRow 17: Sc15, Inc, *Sc16, Inc* (4 times), Sc1. (90 stitches)\nRow 18: Sc1, Inc, *Sc21, Inc* (3 times), Sc22. (94 stitches)\nRow 19: Sc20, Inc, *Sc17, Inc* (4 times), Sc1. (99 stitches)\nRow 20: Sc2, Inc, *Sc23, Inc* (3 times), Sc24. (103 stitches)\nRow 21: Sc15, Inc, *Sc24, Inc* (3 times), Sc12. (107 stitches)\nRow 22: Sc2, Inc, Sc52, Inc, Sc51. (109 stitches)\nRow 23: Sc29, Inc, Sc53, Inc, Sc25. (111 stitches)\nRow 24: Sc2, Dec, Sc53, Dec, Sc52. (109 stitches)\nRow 25: Sc28, Dec, Sc52, Dec, Sc25. (107 stitches)\nRow 26: Sc15, Dec, *Sc24, Dec* (3 times), Sc12. (103 stitches)\nRow 27: Sc2, Dec, *Sc23, Dec* (3 times), Sc24. (99 stitches)"}︡{"stdout":"\nRow 28: Sc20, Dec, *Sc17, Dec* (4 times), Sc1. (94 stitches)\nRow 29: Sc1, Dec, *Sc21, Dec* (3 times), Sc22. (90 stitches)\nRow 30: Sc15, Dec, *Sc16, Dec* (4 times), Sc1. (85 stitches)\nRow 31: Sc6, Dec, *Sc15, Dec* (4 times), Sc9. (80 stitches)\nRow 32: Sc13, Dec, *Sc14, Dec* (4 times), Sc1. (75 stitches)\nRow 33: Sc5, Dec, *Sc10, Dec* (5 times), Sc8. (69 stitches)\nRow 34: Sc6, Dec, *Sc11, Dec* (4 times), Sc9. (64 stitches)\nRow 35: Dec, *Sc10, Dec* (4 times), Sc14. (59 stitches)\nRow 36: Sc9, Dec, *Sc7, Dec* (5 times), Sc3. (53 stitches)\nRow 37: Dec, *Sc8, Dec* (4 times), Sc11. (48 stitches)\nRow 38: Sc4, Dec, *Sc7, Dec* (4 times), Sc6. (43 stitches)\nRow 39: Dec, *Sc6, Dec* (4 times), Sc9. (38 stitches)\nRow 40: Sc3, Dec, *Sc5, Dec* (4 times), Sc5. (33 stitches)\nRow 41: *Sc3, Dec* (6 times), Sc3. (27 stitches)\nRow 42: *Sc3, Dec* (5 times), Sc2. (22 stitches)\nRow 43: Sc4, Dec, *Sc1, Dec* (5 times), Sc1. (16 stitches)\nIf you want a stuffed shape, firmly stuff your object with fiber fill.\nRow 44: *Sc1, Dec* (5 times), Sc1. (11 stitches)\nRow 45: Sc4, Dec, *Sc-1, Dec* (5 times). (5 stitches)\nBefore tying off, top off the stuffing, if using. To close the surface, cut the yarn leaving a generous tail, thread a tapestry needle with the tail, and weave through the stitches in the last row. Pull to tighten and tie off.\nRow measurements were taken at the following coordinates: [(-2, 0), (-1.95000000000000, 0.197500000000000), (-1.90000000000000, 0.390000000000000), (-1.85000000000000, 0.577500000000000), (-1.79000000000000, 0.795900000000000), (-1.74000000000000, 0.972400000000000), (-1.68000000000000, 1.17760000000000), (-1.62000000000000, 1.37560000000000), (-1.56000000000000, 1.56640000000000), (-1.50000000000000, 1.75000000000000), (-1.44000000000000, 1.92640000000000), (-1.37000000000000, 2.12310000000000), (-1.30000000000000, 2.31000000000000), (-1.22000000000000, 2.51160000000000), (-1.14000000000000, 2.70040000000000), (-1.06000000000000, 2.87640000000000), (-0.969999999999999, 3.05910000000000), (-0.869999999999999, 3.24310000000000), (-0.769999999999999, 3.40710000000000), (-0.649999999999999, 3.57750000000000), (-0.519999999999999, 3.72960000000000), (-0.369999999999999, 3.86310000000000), (-0.199999999999999, 3.96000000000000), (1.33226762955019e-15, 4.00000000000000), (0.200000000000002, 3.96000000000000), (0.370000000000002, 3.86310000000000), (0.520000000000002, 3.72960000000000), (0.650000000000002, 3.57750000000000), (0.770000000000002, 3.40710000000000), (0.870000000000002, 3.24310000000000), (0.970000000000002, 3.05910000000000), (1.06000000000000, 2.87639999999999), (1.14000000000000, 2.70039999999999), (1.22000000000000, 2.51159999999999), (1.30000000000000, 2.30999999999999), (1.37000000000000, 2.12309999999999), (1.44000000000000, 1.92639999999999), (1.50000000000000, 1.74999999999999), (1.56000000000000, 1.56639999999999), (1.62000000000000, 1.37559999999999), (1.68000000000000, 1.17759999999999), (1.74000000000000, 0.972399999999990), (1.79000000000000, 0.795899999999989), (1.85000000000000, 0.577499999999989), (1.90000000000000, 0.389999999999989), (1.95000000000000, 0.197499999999988)]\n"}︡{"done":true}
︠2338e82e-9d6b-4906-aa48-416c9822b6a9s︠
f(x)=(4-x)^(1/2)
a=1
b=3.99
S=18
R=22
scale=1
Pattern(f,a,b,S,R,scale)
︡fd2d6735-e6ea-4689-9d44-adcc5226faf7︡{"stdout":"Row 0: Chain 49. Join work and Sc49. Place marker for beginning of round; move marker up as each round is completed."}︡{"stdout":"\nRow 1: Sc11, Dec, Sc22, Dec, Sc12. (47 stitches)\nRow 2: Sc45, Dec. (46 stitches)\nRow 3: Sc10, Dec, Sc21, Dec, Sc11. (44 stitches)\nRow 4: Sc42, Dec. (43 stitches)\nRow 5: Sc9, Dec, Sc19, Dec, Sc11. (41 stitches)\nRow 6: *Sc18, Dec* (2 times), Sc1. (39 stitches)\nRow 7: Sc8, Dec, Sc29. (38 stitches)\nRow 8: *Sc17, Dec* (2 times). (36 stitches)\nRow 9: Sc7, Dec, Sc16, Dec, Sc9. (34 stitches)\nRow 10: *Sc15, Dec* (2 times). (32 stitches)\nRow 11: Sc6, Dec, Sc14, Dec, Sc8. (30 stitches)\nRow 12: Sc3, Dec, *Sc8, Dec* (2 times), Sc5. (27 stitches)\nRow 13: Sc5, Dec, Sc11, Dec, Sc7. (25 stitches)\nRow 14: *Sc6, Dec* (3 times), Sc1. (22 stitches)\nRow 15: Sc2, Dec, *Sc5, Dec* (2 times), Sc4. (19 stitches)\nRow 16: *Sc4, Dec* (3 times), Sc1. (16 stitches)\nRow 17: *Sc2, Dec* (4 times). (12 stitches)\nRow 18: *Dec* (5 times), Sc2. (7 stitches)\nTo close the surface, cut the yarn leaving a generous tail, thread a tapestry needle with the tail, and weave through the stitches in the last row. Pull to tighten and tie off.\nRow measurements were taken at the following coordinates: [(1, sqrt(3)), (1.18000000000000, 1.67928556237467), (1.35000000000000, 1.62788205960997), (1.53000000000000, 1.57162336455017), (1.71000000000000, 1.51327459504216), (1.88000000000000, 1.45602197785610), (2.06000000000000, 1.39283882771841), (2.23000000000000, 1.33041346956501), (2.40000000000000, 1.26491106406735), (2.57000000000000, 1.19582607431014), (2.74000000000000, 1.12249721603218), (2.91000000000000, 1.04403065089105), (3.08000000000000, 0.959166304662544), (3.24000000000000, 0.871779788708137), (3.39999999999999, 0.774596669241488), (3.54999999999999, 0.670820393249945), (3.68999999999999, 0.556776436283014), (3.81999999999998, 0.424264068711948), (3.92999999999998, 0.264575131106494)]\n"}︡{"done":true}
︠0c18a341-534e-4fbc-85ca-e80e63e0f7b5︠









