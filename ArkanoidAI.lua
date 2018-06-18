
local score_hundred= 0x0373;
local score_tens=0x0374;
local score_unit =0x0375;
local lives_addr=0x000D;
local ball_pos_y_addr=0x0037;
local ball_pos_x_addr=0x0038;
local no_of_blocks_addr=0x000F;
local pad_addr=0x011C;
local death_adr=0x0081;
local i=0;
local control_len=15;
local control_buffer = 5;
local population=100;
local gen = 0
local j =0;
local gen=0;
local avg_fit=0
local best_fit=0
local best_player = {}
local best_flag = 1
local player={};     
local avg_fitness=0
local max_used_control=0
local is_dead=memory.readbyte(death_adr);
local winner={}
winner[3]=false;
local percentile=.3
local mutation_rate = 1
local prev_best = 0
local life = 0
local max_score = 50000

function create_member(sz)
	r='';
	for i=1,sz do
		k=math.random(0,1);
		r=r..k;
	end
	return r;
end

function generate(  )
	local playr={};
	for i=1, population do
		tmp={};
		tmp[1]="";
		for j=1, control_len do
			tmp[1]=tmp[1]..math.random(0,1);
		end
	tmp[2]=0;
	playr[i]=tmp;
	end
	return playr
end


function mutation( playx )
	for i =1, population do
        for j=1, control_len do
            if math.random(0,100)<=mutation_rate then
                playx[i][1]=string.sub(playx[i][1],1,j-1)..math.random(0,1)..string.sub(playx[i][1],j+1)
            end
        end
    end
    return playx
end



function cross( playx,n_control)
	local playr = {};
	l=math.floor(percentile*population)
	
    for i=1, l do
    	table.insert(playr,playx[i])
    end

    if prev_best == best_fit then
    	best_flag = 0;
    elseif prev_best ~= best_flag then
    	best_flag = 1;
    end
    if max_used_control == control_len then
    	best_flag = 1;
    end

    if best_flag ==1 then
	    for i=1,l do
			playx[i][1]=string.sub(playr[i][1],1,control_len)..create_member(control_buffer);
		end
	    control_len= control_len + control_buffer;
	end
	
	for i=1,l do
	    playx[i][2]=0
	end

    for i=l+1,population do
    	playx[i][2]=0
        p1=math.random(1,l)
        p2=math.random(1,l)
        k=math.random(1,100)
        y=control_len/2
        if k<=50 then
        	if math.random(0,1) ==0 then
				playx[i][1]=string.sub(playr[p1][1],1,max_used_control-2)..string.sub(playr[p2][1],max_used_control-2,control_len);
			else
				playx[i][1]=string.sub(playr[p2][1],1,max_used_control-2)..string.sub(playr[p1][1],max_used_control-2,control_len);
			end
        elseif (k>50 and k<=92) then
        	if math.random(0,1) ==0 then
	        	playx[i][1]=string.sub(playr[p1][1],1,max_used_control-2)..string.sub(playr[p2][1],1,control_len - max_used_control-2);
			else
				playx[i][1]=string.sub(playr[p2][1],1,max_used_control-2)..string.sub(playr[p1][1],1,control_len - max_used_control-2);
	        end
	    elseif (k==93) then
	    	x=math.random(max_used_control-2,control_len-1)
	    	playx[i][1]=string.sub(playr[p1][1],1,x)..string.sub(playr[p2][1],x+1,control_len)
	    elseif (k==94) then
	    	x=math.random(max_used_control-2,control_len-1)
	    	playx[i][1]=string.sub(playr[p2][1],1,x)..string.sub(playr[p1][1],x+1,control_len)
	    elseif (k==95) then
	    	x=math.random(1,y-1)
	    	playx[i][1]=string.sub(playr[p1][1],1,x)..string.sub(playr[p2][1],x+1,x+x)..string.sub(playr[p1][1],x+x+1,control_len)
	    elseif (k==96) then
	    	x=math.random(1,y-1)
	    	playx[i][1]=string.sub(playr[p2][1],1,x)..string.sub(playr[p1][1],x+1,x+x)..string.sub(playr[p2][1],x+x+1,control_len)
	    elseif (k==97) then
	    	playx[i][1]=string.sub(playr[p1][1],1,y)..string.sub(playr[p2][1],y+1,control_len)
  		elseif (k==98) then
	    	playx[i][1]=string.sub(playr[p2][1],1,y)..string.sub(playr[p1][1],y+1,control_len)
	    elseif (k==99) then
	    	local s = ""
	    	local flag_alter = 0
	    	for z=1,control_len do
	    		if flag_alter == 0 then
	    			s=s..string.sub(playr[p2][1],z,z)
	    			flag_alter=1
	    		else
	    			s=s..string.sub(playr[p1][1],z,z)
	    			flag_alter=0
	    		end
	    	end
	    	playx[i][1]=s
	    elseif  (k==100) then
	    	local s = ""
	    	local flag_alter = 0
	    	for z=max_used_control-2,control_len do
	    		if flag_alter == 0 then
	    			s=s..string.sub(playr[p2][1],z,z)
	    			flag_alter=1
	    		else
	    			s=s..string.sub(playr[p1][1],z,z)
	    			flag_alter=0
	    		end
	    	end
	    	playx[i][1]=s
	    end

    end	

   
    --print(playx)
    return playx

end

math.randomseed(os.time());
ss=savestate.create();
savestate.save(ss);
player=generate();


while true do
	gen=gen+1;
	avg_fit=0
	avg_fitness=0
	--print(#player[2][1])
	for i=1,population do
		savestate.load(ss)
		local ball_pos_y=memory.readbyte(ball_pos_y_addr);
		local no_blocks=memory.readbyte(no_of_blocks_addr);
		local pad_pos=memory.readbyte(pad_addr);
		local ball_pos_x=memory.readbyte(ball_pos_x_addr);
		life=memory.readbyte(lives_addr);
		local score=0;
		local diff;
		local intial_blocks=no_blocks
		local play =player[i]
		local controls_used=0
		--[[if winner[3] == true then
			play = winner
		end]]
		--print(#play[1])
		--print(control_len)
		dead_flag =0
		for j=1, control_len do
			controls_used=controls_used+1
			for q=1,25 do

				ball_pos_y=memory.readbyte(ball_pos_y_addr);
				no_blocks=memory.readbyte(no_of_blocks_addr);
				pad_pos=memory.readbyte(pad_addr);
				ball_pos_x=memory.readbyte(ball_pos_x_addr);
				is_dead=memory.readbyte(death_adr);
				--print(pad_pos);
				local lrv;

				if string.sub(play[1],j,j)=='0' then
					lrv=true;
				else
					lrv=false;
				end

				
					--local lrv = math.random(1, 10) > 5;
		    	tbl={
		        	up      = 0,
		        	down    = 0,
		        	left    = lrv,
		        	right   = not lrv,
		        	A       = 0,
		        	B       = 0,
		        	start   = false,
		        	select  = false
		        	};
		        joypad.set(1,tbl);
				gui.text(0, 9, "pop: "..i);
				gui.text(0,19, "gen: "..gen)
				gui.text(0,29, "best: "..best_fit)
				--gui.text(0,39, "cntrl: "..controls_used)
				--gui.text(0,49, "mctrl: "..max_used_control)
				gui.text(0,39, "winner: "..tostring(winner[3]))
				score=memory.readbyte(score_hundred)*100+memory.readbyte(score_tens)*10+memory.readbyte(score_unit);
				emu.frameadvance();

						
				if is_dead==0 and dead_flag ==0 then
					dead_flag=1
					if controls_used > max_used_control then
					max_used_control= controls_used;
					end
					break;
				end
			end
			if is_dead==0 then
				break;
			end
				
		end
		
		is_dead=memory.readbyte(death_adr);
		if is_dead~=0 then
				best_flag = 1;
		end	
		fitblck =(1-no_blocks/intial_blocks)*100
		fitscore = (score/max_score)*100
		fit=(fitscore+fitblck)/2
		play[2] = fit
		if fit > best_fit then
			best_fit=fit
			best_player=play
		end
		if no_blocks == 0 then
			winner=play
			winner[3]=true;
		end
		if pad_pos>=180 or pad_pos<=10 then
			winner=play
			winner[3]=true;
		end

		
		player[i]=play
		avg_fit=avg_fit+fit


	end
	avg_fitness= avg_fit/population
	print(avg_fitness)
	--print(player)
	table.sort( player, 
		function(a,b) 
			if  a[2] > b[2] then 
				return true 
			else 
				return false
			end
		end );
	player=cross(player);
	--[[if prev_best == best_fit then
		mutation_rate=mutation_rate+1
		if mutation_rate>= 5 then
			mutation_rate =5
		end
	else
		mutation_rate=mutation_rate-2
		if mutation_rate<= 0 then
			mutation_rate =1
		end
	end]]
	prev_best=best_fit
	player=mutation(player);
	--print(player)



end

