scenario = "First-order Rule trial"; #Name, used for references 
scenario_type = fMRI_emulation; #Refer to documentation - switch for developing vs production.
#scenario_type = fMRI; #Refer to documentation - switch for developing vs production.
default_font_size = 48;
default_optimize = false; #Leave false for more modern hardware
active_buttons = 5; #How many buttons
button_codes = 1,2,3,4,5; #What they should be coded as, used as a return when pressed. 
target_button_codes = 1,2,3,4,5;
response_logging = log_active; # If response_logging is log_active, responses that are ignored during a trial do not appear in the logfile.
response_matching = simple_matching;   # to use the newer features available in versions above 0.47.
scan_period = 2000; #The value of this parameter should be the time between complete MRI scans. For use with fMRI_emulation type.
default_background_color = 179, 179, 179;
pulses_per_scan = 1; #Needed if there are multiple pulses per TR.
pulse_code = 6;

#########-START SDL-#########
begin;
#########-START Instruction Cues-#########
array {
   LOOP $i 4; #How many cues
   $k = '$i + 1';
   bitmap { filename = "1stRInstructionCues\\InstructionCue$k.png"; description = "$k"; } "ic$k"; 
   ENDLOOP;
} instructioncues_array;
#########-END Instruction Cues-#########
#########-START Feedback Picture-#########
#Files can be swapped, but logic depends on order. 
array {
   bitmap { filename = "Feedback\\Correct.png"; description = "correct"; } correct;
   bitmap { filename = "Feedback\\Incorrect.png"; description = "incorrect"; } incorrect;
	bitmap { filename = "Feedback\\Missed.png"; description = "missed"; } missed;
} feedback_array;
#########-END Feedback Pictures-#########
#########-START Go Picture-#########
picture { background_color = 179,179,179; bitmap { filename = "Feedback\\go.png"; }; x = 0; y = 0; } go_pic;
#########-END Go Picture-#########
#########-START Response Cues-#########
#integeger specifies how many ResponseCue .png's to look for
array {
   LOOP $i 25; #How many cues
   $k = '$i + 1';
   bitmap { filename = "ResponseCues\\ResponseCue$k.png"; description = "$k"; } "rc$k"; 
   ENDLOOP;
} responsecues_array;
#########-END Response Cues-#########
#########-START Trial Declarations-#########
trial{
	trial_duration = forever;
	trial_type = specific_response;
	terminator_button = 5;
	stimulus_event{
		picture{
			text { caption ="Please Wait"; 
			font_size = 80; 
			font_color = 0,0,0;
			}; x = 0; y = 0; 
	};
	}waiting;
}waiting_trial; #This is the Waiting period. It waits for a spacebar to proceed.
trial{
	trial_type = fixed;
	trial_duration = 10000;
	stimulus_event{
		picture{
			text { caption ="+"; 
			font_size = 100; 
			font_color = 0,0,0; 
			}; 
			x = 0; y = 0; 
		}; 
		duration = 10000;
	}fixationcross;
} fixationcross_trial;
trial{
	trial_type = fixed;
	stimulus_event{
		picture {};
		code = "jitter1";
		time = 0;
	} stim_event1; #jitter
	stimulus_event{
		picture { bitmap "ic1"; x = 0; y = 0; } instruction_pic;
	} stim_event2; #Instruction Cue
	stimulus_event{
		picture {} default2;
		code = "jitter2";
	} stim_event3; #jitter
} instructioncueperiod_trial;
trial{
   trial_type = fixed;
	stimulus_event{		
		picture {} default3;
		code = "jitter3";
	} stim_event4; #jitter
	stimulus_event{
		picture go_pic;
		code = "go";
	} stim_event5; #Go
	stimulus_event{
		picture { bitmap rc1; x = 0; y = 0; } response_pic;
		response_active = true; 
	} stim_event6; #ResponseCue
} responseperiod_trial;
trial{
   trial_type = fixed;
	stimulus_event{
		picture { bitmap correct; x = 0; y = 0; } feedback_pic;
		duration = next_picture;
		code = "fbpic";
	} stim_event7; #Feedback
	stimulus_event{
		picture {} default4;
		code = "jitter4"; 
	} stim_event8; #jitter 4 
} feedback_trial;
#########-END Trial Declarations-#########
#########-END SDL-#########
#########-START PCL-#########
begin_pcl;
#Creates Logfile Output
string filename = logfile.subject() + "1stR PrintOut";
if file_exists( logfile_directory + filename + ".txt" ) then 
	int n = 1;
	loop until !file_exists( logfile_directory + filename + string( n ) + ".txt" )
	begin 
		n = n + 1;
	end;
	filename = filename + string (n);
end;
output_file output = new output_file; #creates output file variable
output.open( filename + ".txt", false); #creates and names output file
output.print( "Subject Name: " );
output.print( logfile.subject() ); #prints Subject Name/ID
output.print("\n"); #then inserts a line break
output.print("\n");
#########-START Declared Timings - Variables -######### 
int ict = 500; #Timing for Instruction Cues in miliseconds 
int gt = 250; #Timing for Go! Cue in miliseconds
int rct = 1000; #Timing for Response Cues in miliseconds
int fbt = 250; #Timing for Feedback in miliseconds
int ipt = 4000; #Timing for Instruction Period in miliseconds
int rpt = 4000; #Timing for Response/Feedback Period in miliseconds
int rctt = rct + gt + fbt; #Total timing for cues and feedback
#########-END Declared Timings - Variables-#########
#########-START Print Declared Timings-#########
output.print( "Instruction Cue Time: " );
output.print( ict );
output.print("\n");
output.print( "Go Time: " );
output.print( gt );
output.print("\n");
output.print( "Reaction Cue Time: " );
output.print( rct );
output.print("\n");
output.print( "Feedback Time: " );
output.print( fbt );
output.print("\n");
output.print( "Instruction Period Time: " );
output.print( ipt );
output.print("\n");
output.print( "Response Period Time: " );
output.print( rpt );
output.print("\n");
output.print("\n");
#########-END Print Declared Timings-#########


#########-START Correct Answers Array-#########
array<int> correct_array[4] = {1,2,3,4};
#########-END Correct Answers Array-#########


#########-START Subroutine to Count MRI Pulses-#########
sub wait_for_pulse ( int pulse_num )
	begin
	loop until pulse_manager.main_pulse_count() > pulse_num
	begin
	end;
end;
#########-END Subroutine to Count MRI Pulses-#########


#########-START Please Wait and Fixation Cross-#########
waiting_trial.present();
wait_for_pulse( pulse_manager.main_pulse_count() + 1 ); #Inserts waits to sync beginning of Fixation Cross Trial with MRI Pulse
fixationcross_trial.present();
#########-END Please Wait and Fixation Cross-#########


#########-START Trial Logic-#########
loop int i = 1 until i > 25
begin
	
	int x = random(100,3400); #Randomly chooses jitter 1
	int y = ipt - ict - x; #Uses set integers above to determie jitter 2.
	int a = random(100,2400); #Randomly chooses jitter 3. 
	int b = rpt - rct - gt - fbt - a; #Uses set integers above to determie jitter 4.
	instructioncues_array.shuffle();
	responsecues_array.shuffle();
	int ica = int(instructioncues_array[1].description()); 
	int rca = int(responsecues_array[1].description());
	
	
#Assigning Times
	instructioncueperiod_trial.set_duration( ipt );
	stim_event1.set_duration( next_picture );
	
	stim_event2.set_duration( ict );
	stim_event2.set_delta_time( x );
	
	stim_event3.set_delta_time( ( ict ) );
	stim_event3.set_duration( y );
	
	responseperiod_trial.set_duration( a + rct + gt );

	stim_event4.set_duration( next_picture );
	
	stim_event5.set_duration( gt );
	stim_event5.set_delta_time( a );
	
	stim_event6.set_duration( rct );
	stim_event6.set_delta_time( gt );
	
	feedback_trial.set_duration( b + fbt );
	
	stim_event7.set_duration( next_picture );
	
	stim_event8.set_duration( b );
	stim_event8.set_delta_time( fbt );
				
#Logic for instruction cues.
	instruction_pic.set_part( 1, instructioncues_array[1] );
	stim_event2.set_event_code( instructioncues_array[1].description() );
	
	instructioncueperiod_trial.present();
	
#Logic for response cues.
	response_pic.set_part( 1, responsecues_array[1] );
	stim_event6.set_event_code( responsecues_array[1].description() );
	stim_event6.set_target_button(correct_array[ica]);
	responseperiod_trial.present();
	
#Logic for feedback. 
	stimulus_data last = stimulus_manager.last_stimulus_data();
   if last.reaction_time() >= rct || last.reaction_time() <= 0 then
		feedback_pic.set_part( 1, feedback_array[3] ); #For Misses
		stim_event7.set_event_code("miss");
	else 
		if last.button() == correct_array[ica] then
			feedback_pic.set_part( 1, feedback_array[1] ); #For Correct
			stim_event7.set_event_code("correct");
		else 
			feedback_pic.set_part( 1, feedback_array[2] ); #For Incorrect
			stim_event7.set_event_code("incorrect");
		end;
	end;
	feedback_trial.present();
		
#Print Important Values
output.print("Start Trial ");
output.print( i );
output.print(".");
output.print("\n");

output.print( "Jitter 1 : " );
output.print( x );
output.print("\n");

output.print( "Instruction Cue : " );
output.print( instructioncues_array[1].description() );
output.print("\n");

output.print( "Jitter 2 : " );
output.print( y );
output.print("\n");

output.print( "Jitter 3: " );
output.print( a );
output.print("\n");

output.print( "Response Cue: " );
output.print( responsecues_array[1].description() );
output.print("\n");

output.print( "Reaction Time: " );
output.print(last.reaction_time());
output.print("\n");

output.print( "Correct Button: " );
output.print(correct_array[ica]);
output.print("\n");

output.print( "Button Pressed: " );
output.print(last.button());
output.print("\n");

output.print( "Jitter 4: " );
output.print( b );
output.print("\n");

output.print("End Trial ");
output.print( i );
output.print(".");
output.print("\n");
output.print("\n");

#Logic to end loop and start next trial.
   i = i + 1;
end;