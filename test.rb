=begin
  Programmer: David McPfimeloronti
  Project: Euler 54 for Spreemo

  This program is designed to read a series of 1000 heads-up poker hands between two players and 
  find the number of times Player #1 won.
=end

# GLOBAL DEFINITIONS ****************************************************************************
$file_name = "c:/Users/David/Desktop/p054_poker.txt"


# CLASS DEFINITION ******************************************************************************

class PokerHand
   def initialize(c1,c2,c3,c4,c5)
	@val = 0
	@cards = Hash.new()
	@flush_possible = true
	@flush_suit = " "
	self.processcard(c1)
	self.processcard(c2)
	self.processcard(c3)
	self.processcard(c4)
	self.processcard(c5)
   end  #initialize

   def processcard(card)

	#get numerical equivalent of the card
	order = card.slice(0)  #1st char is card's order
	case order
	when "T"
	  ordVal = 10
	when "J"
	  ordVal = 11
	when "Q"
	  ordVal = 12
	when "K"
	  ordVal = 13
	when "A"
	  ordVal = 14
	else
	  ordVal = order.to_i()
	end
	@cards.store(card, ordVal)	#put in hash, so later can grab values and sort

	#process suit looking for possible flush
	if @flush_possible then
	  suit = card.slice(-1)   #last char is the suit
	  if suit != @flush_suit then
	    if @flush_suit == " " then 
	      @flush_suit = suit
	    else
	      @flush_possible = false
	    end
	  end
	end  #checking for flush
   end	#process card	

   def value()
      arr = Array.new()		
      straight = false	
      quad = 0
      triple = 0
      pair1 = 0
      pair2 = 0
      kicker = 0

      if @val == 0 then   #only compute value once, even if checked multiple times
	arr = @cards.values()
	arr.sort!   #pull values from hash and sort, low to high

	#check if a straight exist
	if arr[4] == arr[3] + 1 then
	  if arr[3] == arr[2] +1 then
	    if arr[2] == arr[1] + 1 then
	      if arr[1] == arr[0] + 1 then
		straight = true
	      end
	    end
	  end
	end  #straight check

	#walk thru, comparing cards looking for 4,3, and 2 of a kind. since sorted assume simplifying conditions
	if arr[4]==arr[3] then 
	   pair1 = arr[4] 
	end

	if arr[3]==arr[2] then
	   if pair1 == arr[3] then #part of a triple
		triple = arr[4]
		pair1 = 0 
	   else    #new first pair
		pair1 = arr[3]
	   end
	end

	if arr[2]==arr[1] then
	  if triple == arr[2] then # top four of a kind
	 	quad = arr[4]
		triple = 0
	  else 
		if pair1 == arr[2] then #then middle triple
		  triple = arr[2]
		  pair1 = 0
	        else
		  if pair1 > 0 then   #PPx
			pair2 = arr[2]
		  else  #xyPz
			pair1 = arr[2]
		  end   
		end
	   end
	end	 

	if arr[0]==arr[1] then
	  if triple == arr[1] then  #bottom 4 of kind
	 	quad = arr[1]
		triple = 0
	  elsif pair1 == arr[1] then  #low triple
		  triple = arr[1]
		  pair1 = 0
	   elsif pair2 == arr[1] then  #low triple
		     triple = arr[1]
		     pair2 = 0
	   elsif pair1 > 0 then  #PxP
			pair2 = arr[1]
	   else    #xyzP
			pair1 = arr[1]
	   end   
	end	#comparision functions 

	#compute final value
	# first digit is ranked order
	# next two digits are first tie break
	# next two digits are 2nd tie break
	# etc.

	if @flush_possible and straight
	  @val=90000000000 + arr[4]*100000000
	elsif quad != 0
	  @val=80000000000 + quad*100000000
	elsif (triple != 0) and (pair1 !=0)
	  @val=70000000000 + triple*100000000 + pair1*1000000
	elsif @flush_possible
 	  @val=60000000000 + arr[4]*100000000 + arr[3]*1000000 + arr[2]*10000 + arr[1]*100 + arr[0]
	elsif straight	  
	  @val=50000000000 + arr[4]*100000000
	elsif triple != 0
	  @val=40000000000 + triple*100000000
	elsif (pair1 != 0 )and (pair2 !=0)
	  if arr[4] == pair1
	     if arr[2] == pair2
		kicker = arr[0]
	     else
		kicker = arr[2]
	     end
	  else
		kicker = arr[4]
	  end
	  @val=30000000000 + pair1*100000000 + pair2*1000000 + kicker*10000
	elsif pair1 != 0
	  if arr[4] == pair1 then
		kicker = arr[2]*1000000 + arr[1]*10000 + arr[0]*100
	  elsif arr[3] == pair1 then
		kicker = arr[4]*1000000 + arr[1]*10000 + arr[0]*100
	  elsif arr[2] == pair1 then
		kicker = arr[4]*1000000 + arr[3]*10000 + arr[0]*100
	  else 
		kicker = arr[4]*1000000 + arr[3]*10000 + arr[2]*100
	  end
	  @val=20000000000 + pair1*100000000 + kicker
	else
	  @val=10000000000 + arr[4]*100000000 + arr[3]*1000000 + arr[2]*10000 + arr[1]*100 + arr[0]
	end
      end
      @val
   end  #val compute
end  #method value



# MAIN PROGRAM *****************************************************************************

rArr = Array.new(10)
win = 0
IO.foreach($file_name) {|round|   #input assumed "good" so not worrying about error checking
  rArr = round.split(" ")

  #  load player's hands
  play1 = PokerHand.new(rArr[0],rArr[1],rArr[2],rArr[3],rArr[4])
  play2 = PokerHand.new(rArr[5],rArr[6],rArr[7],rArr[8],rArr[9])

  #  if 1 better than 2, increment count
  if (play1.value > play2.value) then
     win += 1
  end
}

#display result
puts "Player 1 won " + win.to_s + " of the contests."

# END MAIN PROGRAM ********************************************************************

=begin  - code for controlled test to confirm all path proper functioning
play1 = PokerHand.new("3H","4H","5H","6H","7H") #straight flush
puts play1.value.to_s
play1 = PokerHand.new("3H","3C","2H","3D","3S") # 4 of a kind, top
puts play1.value.to_s
play1 = PokerHand.new("3H","3C","5H","3D","3S") # 4 of a kind, bottom
puts play1.value.to_s
play1 = PokerHand.new("3H","3C","5H","5D","3S") #full little/big
puts play1.value.to_s
play1 = PokerHand.new("3H","3C","5H","5D","5S") #full big/little
puts play1.value.to_s
play1 = PokerHand.new("3H","TH","5H","AH","7H") # flush
puts play1.value.to_s
play1 = PokerHand.new("3H","7C","5H","6D","4S") # straight
puts play1.value.to_s
play1 = PokerHand.new("2H","5C","5H","5D","3S") # 3 of a kind, top
puts play1.value.to_s
play1 = PokerHand.new("JH","3C","5H","5D","5S") # 3 of a kind, middle
puts play1.value.to_s
play1 = PokerHand.new("JH","8C","5H","5D","5S") # 3 of a kind, bottom
puts play1.value.to_s
play1 = PokerHand.new("3H","5C","5H","6D","6S") # 2 pair; PPx
puts play1.value.to_s
play1 = PokerHand.new("3H","4C","5H","5D","3S") #  2 pair; PxP
puts play1.value.to_s
play1 = PokerHand.new("JH","3C","3H","5D","5S") # 2 pair; xPP
puts play1.value.to_s
play1 = PokerHand.new("JH","8C","3H","JD","5S") # pair; Pxyz
puts play1.value.to_s#=end
play1 = PokerHand.new("QH","7C","5H","7D","4S") # pair; xPyz
puts play1.value.to_s
play1 = PokerHand.new("TH","5C","8H","5D","3S") # pair; xyPz
puts play1.value.to_s
play1 = PokerHand.new("JH","3C","3H","AD","5S") # pair; xyzP
puts play1.value.to_s
play1 = PokerHand.new("JH","8C","7H","3D","5S") # high card
puts play1.value.to_s
=end





