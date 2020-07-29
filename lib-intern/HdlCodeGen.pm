# =============================================================================
# Company      : Unversity of Glasgow, Comuting Science
# Author:        Syed Waqar Nabi
# 
# Create Date  : 2015.03.10
# Project Name : TyTra
#
# Dependencies : 
#
# Revision     : 
# Revision 0.01. File Created
# 
# Conventions  : 
# =============================================================================
#
# =============================================================================
# General Description and Notes:
#
# Verilog Code Generator Module for use with TyBEC
#
# Target is Altera Stratix devices.
# =============================================================================                        

package HdlCodeGen;

use strict;
use warnings;

#use Data::Dumper;
use File::Slurp;
use File::Copy qw(copy);
use List::Util qw(min max);
use Term::ANSIColor qw(:constants);
use Cwd;

use POSIX qw(ceil);

use Exporter qw( import );
our @EXPORT = qw( $genCoreComputePipe );


our $TyBECROOTDIR = $ENV{"TyBECROOTDIR"};

our $singleLine ="// -----------------------------------------------------------------------------\n";

# ============================================================================
# Utility routines
# ============================================================================

sub log2 {
        my $n = shift;
        return int( (log($n)/log(2)) + 0.99); #0.99 for CEIL operation
    }

#This subroutine overwrites input string     
sub remove_duplicate_lines {    
      my %seen;
      my @outbuff; 
      my @lines = split /\n/, $_[0];
      foreach my $line (@lines) {
        push @outbuff, $line if !$seen{$line}++;   # print if a line is never seen before
      }
      $_[0] = join ("\n",@outbuff);
}    

#one-shot coding for implementing mux logic in pndmap wrapper
sub oneshot {
  my $t = shift; #the current thread being coded
  my $n = shift; #total threads (i.e., total encoding bits
  my $str = '0' x $n;
  #substr EXPR,OFFSET,LENGTH,REPLACEMENT
  substr ($str, ($n-1-$t), 1, '1');
  #print "oneshot returns $str\n";
  return ($str);
}
# ============================================================================
# Code Generation Lookups
# ============================================================================

# >>> Which (pipelined) module to use for which operation (and datatype)
our %mod4op;

$mod4op{add}{ui18} = 'PipePE_ui_add';
$mod4op{sub}{ui18} = 'PipePE_ui_sub';
$mod4op{mul}{ui18} = 'PipePE_ui_mul';
$mod4op{add}{ui32} = 'PipePE_ui_add';
$mod4op{sub}{ui32} = 'PipePE_ui_sub';
$mod4op{mul}{ui32} = 'PipePE_ui_mul';

# >>> Which combinational connector to use for which operation
our %conn4op;
$conn4op{and} = '&';
$conn4op{or}  = '|';

# what is the width in bits for a particular data type
  # TODO: something of a hack... this should be more centralized some ways
our %width4dtype;

$width4dtype{ui18} = 18;



# ============================================================================
# GENERATE AXI FIFO BUFFER
# ============================================================================

sub genAxiStreamBuffer {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$hashref
      ,$vect
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  my $synthunit   = 'fifobuf';
  my $synthDtype  = $hash{synthDtype};
  my $datat       = $synthDtype; #complete type (e.g i32)    
  (my $dataw = $datat)     =~ s/\D*//g; #width in bits
  (my $dataBase = $datat)  =~ s/\d*//g; #base type (ui, i, or float)
  
  my $buffSizeWords = $hash{bufferSizeWords};
  my @tapsAtDelays  = @{$hash{tapsAtDelays}};
  my $maxDelay      = $buffSizeWords;
    
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);
  
  #sring buffers for code-gen  
  my $str_outputs         ="";
  my $str_oreadys         ="";
  my $str_oreadysAnd      = "assign oready = 1'b1\n";
  my $str_ovalids         ="";
  my $str_assign_ovalids  = "";
  my $str_assign_dataouts = "";
  my $str_reset_data      = "";
  my $str_shift_data_and_valid = "";
  my $str_dont_shift_data_and_valid = "";
  
  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName;
  $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.axiStreamBuff.v";
  
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header and module name 
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;

  # -------------------------------------------------------
  # >>>>> DATAW/STREAMW parameters
  # -------------------------------------------------------
  my $streamw;
  if($dataBase eq 'float')  {$streamw=$dataw+2;}
  else                      {$streamw=$dataw;}

  $genCode =~ s/<dataw>/$dataw/g;
  $genCode =~ s/<streamw>/$streamw/g;
  $genCode =~ s/<size>/$buffSizeWords/g;
      
  # -------------------------------------------------------
  # >>>>> output taps
  # -------------------------------------------------------
  #code required for each output tap
  my $tcount = 0;
  foreach my $tap (@tapsAtDelays) {
    #number each tap consecutively from 1 and up (for compatibility with over generation rules)
    $tcount++;
    
    $str_outputs        .= "  , output     [STREAMW-1:0]  out$tcount // at delay = $tap \n";
    $str_oreadys        .= "  , input                     oready_out$tcount\n";
    $str_oreadysAnd     .= "  & oready_out$tcount\n";
    $str_ovalids        .= "  , output                    ovalid_out$tcount\n";
    $str_assign_ovalids .= "assign ovalid_out$tcount = valid_shifter[$tap-1] & ivalid_in1;\n";
    $str_assign_dataouts.= "assign out$tcount = offsetRegBank[$tap-1]; // at delay = $tap \n";
  }
  
  #create the shift register for data and valid
  #template already has code for $d = 0 (other than reset branch)
  $str_reset_data  .= "    offsetRegBank[0]  <=  $dataw\'b0;\n"; 
  $str_reset_data  .= "    valid_shifter[0]  <=  1'b0;\n"; 
  foreach my $d (1..$maxDelay-1) {
    $str_reset_data                .= "    offsetRegBank[$d]  <=  $dataw\'b0;\n"; 
    $str_reset_data                .= "    valid_shifter[$d]  <=  1'b0;\n"; 
    $str_shift_data_and_valid      .= "    offsetRegBank[$d]  <=  offsetRegBank[$d-1];\n"; 
    $str_shift_data_and_valid      .= "    valid_shifter[$d]  <=  valid_shifter[$d-1];\n"; 
    $str_dont_shift_data_and_valid .= "    offsetRegBank[$d]  <=  offsetRegBank[$d];\n"; 
    $str_dont_shift_data_and_valid .= "    valid_shifter[$d]  <=  valid_shifter[$d];\n"; 
  }
  
  $str_oreadysAnd .= "  ;";
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/<outputs>/$str_outputs/g;
  $genCode =~ s/<oreadys>/$str_oreadys/g;
  $genCode =~ s/<oreadysAnd>/$str_oreadysAnd/g;
  $genCode =~ s/<ovalids>/$str_ovalids/g;
  $genCode =~ s/<assign_ovalids>/$str_assign_ovalids/g;
  $genCode =~ s/<assign_dataouts>/$str_assign_dataouts/g;
  $genCode =~ s/<shift_data_and_valid>/$str_shift_data_and_valid/g;
  $genCode =~ s/<dont_shift_data_and_valid>/$str_dont_shift_data_and_valid/g;
  $genCode =~ s/<reset_data>/$str_reset_data/g;
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
  
  print "TyBEC: Generated module $modName\n";  
} 

# ============================================================================
# GENERATE AXI _STENCIL_ BUFFER
# ============================================================================

sub genAxiStencilBuffer {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$hashref
      ,$vect
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  my $synthunit   = 'smache';
  my $synthDtype  = $hash{synthDtype};
  my $datat       = $synthDtype; #complete type (e.g i32)    
  (my $dataw = $datat)     =~ s/\D*//g; #width in bits
  (my $dataBase = $datat)  =~ s/\d*//g; #base type (ui, i, or float)
  my $maxP = $hash{maxPosOffset};
  my $maxN = $hash{maxNegOffset};
  #my $buffSizeWords = $maxP + $maxN + 1;
  
  #See calculations in <tybec?/docs/stencilbuffers_withvectorization_calculations.xlsx
  my $buffSizeWords = $vect*ceil(($maxP + $maxN + (2*$vect-1))/$vect);
   
  #See calculations in <tybec?/docs/stencilbuffers_withvectorization_calculations.xlsx
  #my $offsetIdx0S0 = $maxP + ($vect-1) + ($vect-1);
  my $offsetIdx0S0 = $maxP + ($vect-1);
  
  #my $maxDelay      = $buffSizeWords;
    
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);
  
  #sring buffers for code-gen  
  my $str_outputs         ="";
  my $str_inputs          ="";
  my $str_ivalids         ="";
  my $str_oreadys         ="";
  my $str_ireadys         ="";
  my $str_assign_ireadys  ="";
  my $str_oreadysAnd      = "assign oready = 1'b1\n";
  my $str_ovalids         ="";
  my $str_assign_ovalids  = "";
  my $str_assign_dataouts = "";
  my $str_shift_data_and_valid = "";
  my $str_shift_data_and_valid_idx0 = "";
  my $str_dont_shift_data_and_valid = "";
#  
  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName;
  $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.axiStencilBuff.v";
  
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header and module name 
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;

  # -------------------------------------------------------
  # >>>>> DATAW/STREAMW parameters
  # -------------------------------------------------------
  my $streamw;
  if($dataBase eq 'float')  {$streamw=$dataw+2;}
  else                      {$streamw=$dataw;}

  $genCode =~ s/<dataw>/$dataw/g;
  $genCode =~ s/<streamw>/$streamw/g;

  # -------------------------------------------------------
  # >>>>> SMACHE design parameters
  # -------------------------------------------------------
  $genCode =~ s/<maxp>/$maxP/g;
  $genCode =~ s/<maxn>/$maxN/g;
  $genCode =~ s/<vect>/$vect/g;
  $genCode =~ s/<size>/$buffSizeWords/g;
  $genCode =~ s/<offsetIdx0S0>/$offsetIdx0S0/g;

  # -------------------------------------------------------
  # >>>>> inputs
  # -------------------------------------------------------
  foreach  my $v (0..$vect-1){
    $str_inputs  .= "  , input  [STREAMW-1:0]  in1_s$v\n";
    $str_ivalids .= "  , input                 ivalid_s$v\n";
    $str_ireadys .= "  , output                iready_s$v\n";
    $str_assign_ireadys .= "assign iready_s$v = oready;\n";
  }
  
  # -------------------------------------------------------
  # >>>>> output taps
  # -------------------------------------------------------
  # other than calculation of buffer address, code gen is same
  # for positive or negative offsets
  # name of output ports in smache, unlike other _leaf_ nodes, is _not_ generic (out1, out2...)
  # Instead, like hierarchical nodes, the output port name is same as the connectio name (that is, the identifier of the
  # stream it is producing
  
  my $firstOffStream = 1; #some things happen only once across all offstreams
  foreach my $offstream (keys %{$hash{offstreams}}) {
    my $dist    = $hash{offstreams}{$offstream}{dist};
    my $dir     = $hash{offstreams}{$offstream}{dir};
    
    $offstream =~ s/(%|@)//g; 
    my $bufAddr;
    my $bufAddrCalc;
    
    #$bufAddr = $maxP-$dist if ($dir eq '+');
    #$bufAddr = $maxP+$dist if ($dir eq '-');
    
    foreach  my $v (0..$vect-1){
      
      #$bufAddr = "OFFSET_IDX0_S0-$dist+$v" if ($dir eq '+');
      #$bufAddr = "OFFSET_IDX0_S0+$dist+$v" if ($dir eq '-');
      
      $bufAddrCalc = $offsetIdx0S0-$dist-$v if ($dir eq '+');
      $bufAddrCalc = $offsetIdx0S0+$dist-$v if ($dir eq '-');
      
      $str_outputs        .= "  , output [STREAMW-1:0]  $offstream\_s$v\n";
      $str_oreadys        .= "  , input                 oready_$offstream\_s$v\n";
      $str_oreadysAnd     .= "  & oready_$offstream\_s$v\n";
      
      if($firstOffStream) {
        $str_ovalids        .= "  , output                ovalid_s$v\n";
        $str_assign_ovalids .= "assign ovalid_s$v = valid_shifter[$offsetIdx0S0] & ivalid_s$v;\n";
      }
      
      
        #the output is "valid" when the maximum POSITIVE offset is in (and thus the *current index* is now at 0)
        #if, at this point, you try to generate and access and _negative_ offsets, you will get garbage values
        #as the current index is at 0, and negative indices dont exist
        #boundary conditions in the subsequent nodes should take care of this (OR, we can emit strobe signals 
        #from the smache
      $str_assign_dataouts.= "assign $offstream\_s$v = offsetRegBank[$bufAddrCalc];\n";    
      
    }
    $firstOffStream = 0 if($firstOffStream);
  }
    
  #loop through the stencil buffer to read in data, with a stride equal to vector size
  for (my $d=0; $d < $buffSizeWords; $d=$d+$vect) { 
    #loop through each scalar in a vector
    foreach my $vv (0..$vect-1) {    
      #indices if current and previous element in the shift register (LHS and RHS)
      my $idx_c = $d+$vv; #index of 0th scalar + offset for this scalar
      #my $idx_p = $d+$vv-1;
      my $idx_p = $d+$vv-$vect; #the previous data to load is $vect distance away

      #zeroth buffer load treated differently (reads directly from inputs)
      if($d == 0){
        $str_shift_data_and_valid_idx0 .= "    offsetRegBank[$idx_c]  <=  in1_s$vv;\n"; 
        $str_shift_data_and_valid_idx0 .= "    valid_shifter[$idx_c]  <=  ivalid_s$vv;\n"; 
      }
      
      else {
        $str_shift_data_and_valid      .= "    offsetRegBank[$idx_c]  <=  offsetRegBank[$idx_p];\n"; 
        $str_shift_data_and_valid      .= "    valid_shifter[$idx_c]  <=  valid_shifter[$idx_p];\n"; 
        $str_dont_shift_data_and_valid .= "    offsetRegBank[$idx_c]  <=  offsetRegBank[$idx_c];\n"; 
        $str_dont_shift_data_and_valid .= "    valid_shifter[$idx_c]  <=  valid_shifter[$idx_c];\n"; 
      }
    }
  }
  
  $str_oreadysAnd .= "  ;";
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/<outputs>/$str_outputs/g;
  $genCode =~ s/<inputs>/$str_inputs/g;
  $genCode =~ s/<ivalids>/$str_ivalids/g;
  $genCode =~ s/<oreadys>/$str_oreadys/g;
  $genCode =~ s/<ireadys>/$str_ireadys/g;
  $genCode =~ s/<assign_ireadys>/$str_assign_ireadys/g;
  $genCode =~ s/<oreadysAnd>/$str_oreadysAnd/g;
  $genCode =~ s/<ovalids>/$str_ovalids/g;
  $genCode =~ s/<assign_ovalids>/$str_assign_ovalids/g;
  $genCode =~ s/<assign_dataouts>/$str_assign_dataouts/g;
  $genCode =~ s/<shift_data_and_valid>/$str_shift_data_and_valid/g;
  $genCode =~ s/<shift_data_and_valid_idx0>/$str_shift_data_and_valid_idx0/g;
  $genCode =~ s/<dont_shift_data_and_valid>/$str_dont_shift_data_and_valid/g;
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
#  
  print "TyBEC: Generated module $modName\n";  
} 

# ============================================================================
# GENERATE AUTOINDEX
# ============================================================================

sub genAutoIndex {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$hashref
      ,$vect
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  my $synthunit   = 'autoindex';
  my $synthDtype  = $hash{synthDtype};
  my $datat       = $synthDtype; #complete type (e.g i32)    
  (my $dataw = $datat)     =~ s/\D*//g; #width in bits
  (my $dataBase = $datat)  =~ s/\d*//g; #base type (ui, i, or float)
  my $startat     = $hash{start};
  my $wrapat      = $hash{end};

  #is this a leaf counter (if not, it nests over another)
  my $cleaf = !(defined ($hash{nestOver}));
  
   
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp           = localtime(time);
  my $str_ports_outputdata='';
  my $str_ports_trig_count='';
  my $str_ports_ivalid    ='';
  my $str_ports_ovalid    ='';
  my $str_ports_trig_wrap ='';
  my $str_assign_ovalids  ='';
  my $str_branch_rst      ='';
  my $str_branch_wrap     ='';
  my $str_branch_count    ='';
  my $str_branch_donothing='';
  my $str_nestingcomment  = $cleaf ? "//This is a leaf counter"
                                   : "//This is a hierarchical counter, nesting over $hash{nestOver}";
   
  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName;
  $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.autocounter.v";
  
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header and module name 
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;  
  $genCode =~ s/<nestingcomment>/$str_nestingcomment/g;  
  
  # ------------------------------------
  # >>>>> Vectorization
  # ------------------------------------
  #only for leaf counter (not nested over another) do we 
  # 1. need to stagger counter outputs per vector lane
  # 2. increment by $vect
  #higher-level counters in a nested situation are the same for all lanes
  #(this presumes $vect divides the size along the inner-most dimension)
  #and also increment by 1
  
  foreach my $v (0..$vect-1) {
    my $offset = $cleaf ? $v    : 0;
    my $inc    = $cleaf ? $vect : 1;
    $str_ports_outputdata .= "  , output reg [COUNTERW-1:0] counter_value_s$v\n";
    $str_ports_trig_count .= "  , input                     trig_count_s$v\n";
    $str_ports_ivalid     .= "  , input                     ivalid_s$v\n";
    $str_ports_ovalid     .= "  , output                    ovalid_s$v\n";
    $str_ports_trig_wrap  .= "  , output                    trig_wrap_s$v\n";
    $str_assign_ovalids   .= "assign ovalid_s$v = ivalid_s0;\n";
    $str_branch_rst       .= "    counter_value_s$v <= STARTAT + $offset;\n";
    $str_branch_wrap      .= "      counter_value_s$v <= STARTAT + $offset;\n";
    $str_branch_count     .= "      counter_value_s$v <= counter_value_s$v + $inc;\n";
    $str_branch_donothing .= "    counter_value_s$v <= counter_value_s$v;\n";
  }
  
  chomp($str_ports_outputdata);
  chomp($str_ports_trig_count);
  chomp($str_ports_ivalid    );
  chomp($str_ports_ovalid    );
  chomp($str_ports_trig_wrap );
  chomp($str_branch_rst      );
  chomp($str_branch_wrap     );
  chomp($str_branch_count    );
  chomp($str_branch_donothing);
  
  # ------------------------------------
  # >>>>> Update tags and write to file
  # ------------------------------------
  $genCode =~ s/<counterw>/$dataw/g;
  $genCode =~ s/<startat>/$startat/g;
  $genCode =~ s/<wrapat>/$wrapat/g;
  $genCode =~ s/<vect>/$vect/g;
  $genCode =~ s/<ports_outputdata>/$str_ports_outputdata/;
  $genCode =~ s/<ports_trig_count>/$str_ports_trig_count/;
  $genCode =~ s/<ports_ivalid>/$str_ports_ivalid/;
  $genCode =~ s/<ports_ovalid>/$str_ports_ovalid/;
  $genCode =~ s/<ports_trig_wrap>/$str_ports_trig_wrap/;
  $genCode =~ s/<assign_ovalids>/$str_assign_ovalids/;
  $genCode =~ s/<branch_rst>/$str_branch_rst/;
  $genCode =~ s/<branch_wrap>/$str_branch_wrap/;     
  $genCode =~ s/<branch_count>/$str_branch_count/;    
  $genCode =~ s/<branch_donothing>/$str_branch_donothing/;
  
  #$genCode =~ s/<outputs>/$str_outputs/g;
  $genCode =~ s/\r//g; #to remove the ^M  

  print $fhGen $genCode;
  print "TyBEC: Generated module $modName\n";  
} 

# ============================================================================
# GENERATE map node -- leaf 
# ============================================================================
#while I have kept the ability to generate vectorized leaf nodes, 
#that is not currently used as the parent/hierarchical nodes
#instantiate multiple instances of their leaf nodes if needed
#for vectorization, so lead nodes are always scalar modules
#TODO: currently I am using separate source templates for each vector size
# no need for this, I should genreate from a common template

sub genMapNode_leaf {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$hashref
      ,$vect
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  my $synthunit   = $hash{synthunit};
  my $synthDtype  = $hash{synthDtype};
  my $datat       = $synthDtype; #complete type (e.g i32)    
  (my $dataw = $datat)     =~ s/\D*//g; #width in bits
  (my $dataBase = $datat)  =~ s/\d*//g; #base type (ui, i, or float)
  
  #is this a reduction operation
  my $redSize = -1; #it is not
  $redSize = $hash{reductionSize} if (defined $hash{reductionSize});


  #need latency to generate correct ovalid signal
  #all leaf nodes (must) have deterministic, fixed latency
  my $lat = $hash{performance}{lat};

  #How many input operands? Code-gen depends on it
  my $nInOps = 2; #default
  $nInOps = 1 if ($synthunit eq 'load'); 
  $nInOps = 1 if ($redSize > 0); 
  $nInOps = 3 if ($synthunit eq 'select') ;
  
  #Vectorization suffix
  my $vsuff = '';
  #my $vsuff = "_s$i"; #obsolete; revive if I ever consider isolated vectorization of leaf nodes
    
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);
  my $strBuf = ""; # temp string buffer used in code generation 
  my $operator = "";
 
  #string for creating input valids, input readys, and output ready ports
  my $str_inputIvalids = "";
  my $str_inputOreadys = "";
  my $str_inputIreadys = "";
  
  #string for ANDING input ivalids and oreadys, and fanning out ireadys
  my $str_inputIvalidsAnded = "";
  my $str_inputOreadysAnded = "";
  my $str_ireadysFanout     = "";
  
  #assigning contant operands their value
  my $str_assignConstants = "";
  
  #fifo buffer instantiated in case this is a fifobuf module
  my $str_instFifoBuff = '';

  #ovalid logic, diff for integer vs float
  my $str_ovalidLogic = '';

  #in case of FP units, 2 MSBs are fixed as per requirements of flopoco
  my $str_fpcEF = "";
  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName;
  #pick up the template file for the appropriate vectorization
  if($vect==1) {$templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.mapnode_leaf.v";}
  else         {$templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.mapnode_leaf_vect$vect.v";}
  
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header and module name 
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;

  # -------------------------------------------------------
  # >>>>> DATAW/STREAMW parameters
  # -------------------------------------------------------
  my $streamw;
  if($dataBase eq 'float')  {$dataw=$dataw+2;}
  else                      {$dataw=$dataw;}
  
  #no need to keep dataw, streamw distinction
  $streamw = $dataw;

  $genCode =~ s/<dataw>/$dataw/g;
  $genCode =~ s/<streamw>/$streamw/g;
  
  #the output stream width is same as STREAMW by default
  my $oStrWidth = "[STREAMW-1:0]";
  #(its 1-bit for compare operation)
  $oStrWidth = "             " if ($synthunit eq 'compare');
  
  # --------------------------------
  # >>>>> port widths initialize
  # --------------------------------
  #the number of inputs and their widths are dependant on operation
  #find out widths first (set width to 0 if port does not exist)
  #by default, first input port exists (does not exist for CONSTANT)
  
  #two inputs ports exist by default, 3rd one doesn't
  my @portW = (-1, $dataw, $dataw,0);
    #first element redundant, only here for 1-based indexing (so that indices match port names which start with 1)
  #my $portWop1 = $dataw;
  #my $portWop2 = $dataw;
  #my $portWop3 = 0;
  
  
  # ---------------------------------------------------------------
  # >>>>> input valids, and output readys (create ports, and them)
  # ---------------------------------------------------------------
  $str_inputIvalidsAnded = "assign ivalid = ";
 my $index = 1;
   
  #I used to have separate iready's for each input, but redundant, a single should
  #be used
  foreach (@{$hash{consumes}}) {
    #check if consumes == produces, 
    #as this is the reduction input, which is handled internally
    if($_ ne $hash{produces}[0]) {
      (my $src = $_) =~ s/\%//;
      $str_inputIvalids       .= "  , input ivalid_in$index\n"; 
      $str_inputIvalidsAnded  .= "ivalid_in$index & ";
    }
    $index++;
  }
  $str_inputIvalidsAnded = $str_inputIvalidsAnded." 1'b1;\n";
  
  # -------------------------------------------------------
  # >>>>> add datapath logic
  # -------------------------------------------------------

  #--------------------------------------------------
  #deal with constant operands
  #-------------------------------------------------- 
  #if any of the input ports are constants, make sure they are not in the port list
  #for (my $i=0; $i<$vect; $i++) {   
  $portW[1] = 0 if(                 ($hash{oper1form} eq 'constant'));
  $portW[2] = 0 if(($nInOps > 1) && ($hash{oper2form} eq 'constant'));
  $portW[3] = 0 if(($nInOps > 2) && ($hash{oper3form} eq 'constant'));
     
  #---------------
  #int
  #---------------
  #some operation in float are treated same as int, so dealt with here
  if ( ($synthDtype =~ m/i\d+/)
     ||(($synthDtype eq 'float32') && (  ($synthunit eq 'load')
                                      || ($synthunit eq 'select')
                                      || ($synthunit eq 'compare_lt')
                                      || ($synthunit eq 'compare_gt')
                                      || ($synthunit eq 'compare_eq')
                                      )
        )                              
     )
  {
  
    #first check if any constant inputs, and assign them to local variables
    #witgh name as they would have had if they were regular ports
    #makes later code generation uniform
    for (my $i=0; $i<$vect; $i++) {
      $str_assignConstants  = $str_assignConstants. "wire [STREAMW-1:0] in1$vsuff\_r = $hash{oper1val};"
        if ($hash{oper1form} eq 'constant');
      $str_assignConstants  = $str_assignConstants. "wire [STREAMW-1:0] in2$vsuff\_r = $hash{oper2val};"
        if (($nInOps > 1) && ($hash{oper2form} eq 'constant'));
      $str_assignConstants  = $str_assignConstants. "wire [STREAMW-1:0] in3$vsuff\_r = $hash{oper3val};"
        if (($nInOps > 2) && ($hash{oper3form} eq 'constant'));
    }
  
    #choose operator symbol (applies for MOST Primitive instructions)
    if    ($synthunit eq 'add')         {$operator = '+';}
    elsif ($synthunit eq 'sub')         {$operator = '-';}
    elsif ($synthunit eq 'mul')         {$operator = '*';}
    elsif ( ($synthunit eq 'udiv')       
          ||($synthunit eq 'sdiv'))     {$operator = '/';}
    elsif ($synthunit eq 'compare_eq')  {$operator = '==';}
    elsif ($synthunit eq 'compare_ne')  {$operator = '!=';}
    elsif ($synthunit eq 'compare_gt')  {$operator = '>';}
    elsif ($synthunit eq 'compare_lt')  {$operator = '<';}
    elsif ($synthunit eq 'or')          {$operator = '|';}
    elsif ($synthunit eq 'and')         {$operator = '&';}
    #treat these specially later
    elsif ($synthunit eq 'select')      {$operator = '';} 
    elsif ($synthunit eq 'load')        {$operator = '';}
    #elsif ($synthunit eq 'pow')      {$operator = '+';} #temp for testing
    else                                {die "TyBEC: Unknown integer operator \"$synthunit\" used\n";}
    

    
    #---------------
    #create DATAPATH
    #---------------
    #depending on number of input operands, undo (or create) input data ports, and 
    for (my $i=0; $i<$vect; $i++) {
      #"select" inst has 3 operands
      if ($nInOps == 3){
        $strBuf   = $strBuf."\nassign out1$vsuff = in1$vsuff\_r ? in2$vsuff\_r : in3$vsuff\_r;";
        #add input port for 3rd (select) source operand, as template has only two by default
        #also first input port is now a single bit
        $portW[1] = 1      unless ($hash{oper1form} eq 'constant');
        #portW[2] already initialized to be dataw, or set to zero if constant
        $portW[3] = $dataw unless ($hash{oper3form} eq 'constant');
      }
      
      #"load"
      #elsif (($nInOps==1) && (synthunit eq 'load')) {
      elsif ($synthunit eq 'load') {
        #$secondOpInputPort = "";
        $portW[2] = 0;
        $strBuf   .= "\nassign out1$vsuff = in1$vsuff\_r;";
      }
      
      #reduction operation
      elsif ($redSize > 0) {
        #I currently limit the syntax to allow the reduction input port (the port common to input and output), ONLY at second position
        #in the generated HDL, that input would be missing, and there will be just one input
        my $w = $portW[1];
        $portW[2] = 0;
        #create a counter to count how many items are to be reduced
        my $rw = log2($redSize+1);
        $strBuf .= "//counter to check if reduction size reached\n";
        $strBuf .= "localparam REDCOUNTLIMIT = $redSize;\n"
                .  "reg [$rw-1:0] red_count;\n"
                .  "always @(posedge clk) begin\n"
                .  "  if(rst) \n"
                .  "    red_count  <= 0;\n"
                .  "  else if (dontStall) \n"
                .  "    if(red_count==REDCOUNTLIMIT-1)\n"
                .  "      red_count  <= 0;\n"
                .  "    else\n"
                .  "      red_count  <= red_count+1;\n"
                .  "  else \n"
                .  "    red_count <= red_count;\n"
                .  "end\n"
                .  "\n";
        #create a "local output ready" to use as trigger for storing the reduced value
        $strBuf .= "//create a local output ready to use as trigger for storing the reduced value\n";
        $strBuf .="reg ovalid_local;\n"
                . "always @(posedge clk) begin\n"
                . "  if(rst)\n"
                . "    ovalid_local <= 0;\n"
                . "//When stalled, SAVE the ovalid_local, so that pipeline continues without having to reload\n"
                . "  else if (~dontStall)\n"
                . "    ovalid_local <= ovalid_local;\n"
                . "  else\n" 
                . "    ovalid_local <= ivalid;\n"
                . "end\n"
                ;
        
        #store reduction output locally
        $strBuf .= "//store reduction output locally\n";
        $strBuf .= "reg [$w-1:0] out1$vsuff\_r;\n"
                .  "always @(posedge clk)\n"
                .  "  if (rst)\n"
                .  "    out1$vsuff\_r <= $w\'b0;\n"
                .  "  else if (ovalid_local)\n"
                .  "    out1$vsuff\_r <= out1$vsuff;\n"
                .  "  else\n"
                .  "    out1$vsuff\_r <= out1$vsuff\_r;\n"
                ;
        $strBuf .= "\nassign out1$vsuff = in1$vsuff\_r ".$operator." out1$vsuff\_r;";
      }
      
      #default units have 2 input operands
      else{
        $strBuf .= "\nassign out1$vsuff = in1$vsuff\_r ".$operator." in2$vsuff\_r;";
      }
    }#for
  }#if
 
  #---------------
  #float
  #---------------
  # Some float operations (select, load) are the same as their integer counterparts, and are dealt with in
  #previous block
  elsif ($synthDtype eq 'float32') {
    
    #first check if any constant inputs, and assign them to local variables
    #witgh name as they would have had if they were regular ports
    #makes later code generation uniform
    #float constants need a little function to convery floating poitn values to equivalent HEX for use in HDL
    sub float2hex {return unpack ('H*' => pack 'f>' => shift)};
    
    #flopoco requires 2 extra bits 
    $str_fpcEF = "wire [1:0] fpcEF = 2'b01;\n";

    for (my $i=0; $i<$vect; $i++) {
      $str_assignConstants  = $str_assignConstants. "wire [STREAMW-1:0] in1$vsuff\_r = {fpcEF, 32'h${\float2hex($hash{oper1val})} };"
        if ($hash{oper1form} eq 'constant');
      $str_assignConstants  = $str_assignConstants. "wire [STREAMW-1:0] in2$vsuff\_r = {fpcEF, 32'h${\float2hex($hash{oper2val})} };"
        if (($nInOps > 1) && ($hash{oper2form} eq 'constant'));
      $str_assignConstants  = $str_assignConstants. "wire [STREAMW-1:0] in3$vsuff\_r = {fpcEF, 32'h${\float2hex($hash{oper3val})} };"
        if (($nInOps > 2) && ($hash{oper3form} eq 'constant'));
    }    
    
    #dependign on operation, move flopoco IP to generated code folder
    #and set module name and instance to use for code generation
    #todo: pre-generated cores are used here. ideally I should
    #generate flopoco at tybec's runtime
    my $flopocoIPFile   ;
    my $flopocoModule   ;
    my $flopopModuleInst;
    my $err             ;
    my $flopocoCoresRoot="$TyBECROOTDIR/hdlCoresTparty/flopoco/cores";
    
    if    ($synthunit eq 'add'){  
      #$flopocoIPFile    = "$flopocoCoresRoot/FPAddSingleDepth7.vhd";
      #$flopocoIPFile    = "$flopocoCoresRoot/FPAddSingleDepth7_stallable.vhd";
      $flopocoIPFile    = "$flopocoCoresRoot/FPAddSingle_Depth7_500Mhz_Virtex6_stallable.vhd";
      #$flopocoModule    = "FPAdd_8_23_F300_uid2";
      $flopocoModule    = "FPAdd_8_23_F500_uid2";
      $flopopModuleInst = "fpAdd";
      $err =copy("$flopocoIPFile", "$outputRTLDir");
    }
    elsif ($synthunit eq 'sub') {
      #$flopocoIPFile    = "$flopocoCoresRoot/FPSubSingleDepth7_stallable.vhd";
      $flopocoIPFile    = "$flopocoCoresRoot/FPSubSingle_Depth7_500Mhz_Virtex6_stallable.vhd";
      #$flopocoModule    = "FPSub_8_23_F300_uid2";
      $flopocoModule    = "FPSub_8_23_F500_uid2";
      $flopopModuleInst = "fpSub";
      $err =copy("$flopocoIPFile", "$outputRTLDir");
    }
    elsif ($synthunit eq 'mul') {
      #$flopocoIPFile    = "$flopocoCoresRoot/FPMultSingleDepth2.vhd";
      #$flopocoIPFile    = "$flopocoCoresRoot/FPMultSingleDepth2_stallable.vhd";
      $flopocoIPFile    = "$flopocoCoresRoot/FPMultSingle_Depth2_500Mhz_Virtex6_stallable.vhd";
      #$flopocoModule    = "FPMult_8_23_8_23_8_23_F400_uid2";
      $flopocoModule    = "FPMult_8_23_8_23_8_23_F500_uid2";
      $flopopModuleInst = "fpMul";
      $err =copy("$flopocoIPFile", "$outputRTLDir");
    }
    elsif ($synthunit eq 'udiv') {
      #$flopocoIPFile    = "$flopocoCoresRoot/FPDivSingleDepth12_stallable.vhd";
      $flopocoIPFile    = "$flopocoCoresRoot/FPDivSingle_Depth12_500Mhz_Virtex6_stallable.vhd";
      #$flopocoModule    = "FPDiv_8_23_F300_uid2";
      $flopocoModule    = "FPDiv_8_23_F500_uid2";
      $flopopModuleInst = "fpDiv";
      $err =copy("$flopocoIPFile", "$outputRTLDir");
    
    }
    else                        {die "TyBEC: Unknown float operator <$synthunit> used (for module $modName)\n";}    
    
    #instantiate flopoco IP in the node module

    for (my $v=0; $v<$vect; $v++) {
      $strBuf .= $strBuf ."$flopocoModule  $flopopModuleInst$vsuff\n"
                      ."  ( .clk (clk)     \n"
                      ."  , .rst (rst)     \n"
                      ."  , .stall (~dontStall)     \n"
                      ."  , .X   (in1$vsuff"."_r)     \n"
                      ."  , .Y   (in2$vsuff"."_r)     \n"
                      ."  , .R   (out1$vsuff)\n"
                      .");"
                      ;
    }#for                      
  }#if float

  #--------------------------------
  #types other than int and float?
  #--------------------------------
  else {die "TyBEC: only intNN and float32 currently supported for code generation\n";}
  
  
    #---------------
    #ovalid logic
    #---------------
    #TODO: No need to have separate branchs for genersting int (1 cycle latecy) and float (n-cycle latency)
    #ovalid logic as the same loop should work ok for 1-cycle latency
    $str_ovalidLogic  .="//output valid\n"
                      . "//follows ivalid with an N-cycle delay (latency of this unit)\n"
                      . "//Also, only asserted with no back-pressure (oready asserted)\n"
                      ;
    #ovalid logic for floats; propagate ivalid along a shift register
    if ($synthDtype eq 'float32') {
      $str_ovalidLogic  .= "reg [$lat-1:0] valid_shifter;\n"
                        .  "always @(posedge clk) begin\n"
                        .  "  if(ivalid) begin\n"
                        .  "    valid_shifter[0] <= ivalid;\n"
                        ;
      
      #start shifting TO index 1, as 0th index does not follow pattern
      foreach my $d (1..$lat-1) {
        $str_ovalidLogic .= "    valid_shifter[$d]  <=  valid_shifter[$d-1];\n"; 
      }                        
      
      $str_ovalidLogic  .= "  end\n";
      $str_ovalidLogic  .= "  else begin\n";
      
      foreach my $d (0..$lat-1) {
        $str_ovalidLogic .= "    valid_shifter[$d]  <=  valid_shifter[$d];\n"; 
      }                        
      $str_ovalidLogic  .= "  end //else\n";
      $str_ovalidLogic  .= "end //always\n";
### >>>> synch debug
      #Why not this, why the other? This seems to have worked for the results in the hindawi paper.
      $str_ovalidLogic  .= "\nassign ovalid = valid_shifter[$lat-1] & oready;\n"; 
      
      #This would be needed when there are stalling nodes, but otherwise? [E.g., would the memory stall the pipeline?]
      #$str_ovalidLogic  .= "\nassign ovalid = valid_shifter[$lat-1] & dontStall;\n"; 
      
      ##ADD branch here for when we have a stall, like there is for int (store valid-shifter state)... TODO

    } 

    #ovalid logic for ints
    else {
      $str_ovalidLogic  .= "reg ovalid_pre;\n";
      
      #not reduction
      if($redSize < 0) {
      #When pipeline is stalled, SAVE the ovalid, so that pipeline continues without having to reload
      $str_ovalidLogic  .="always @(posedge clk) begin\n"
                        . "  if(rst)\n"
                        . "    ovalid_pre <= 0;\n"
                        . "//When stalled, SAVE the ovalid, so that pipeline continues without having to reload\n"
                        . "  else if (~dontStall)\n"          #WN
                        . "    ovalid_pre <= ovalid_pre;\n"   #WN
                        . "  else\n" 
### >>>> synch debug
                        . "    ovalid_pre <= ivalid & oready;\n" 
                        #. "    ovalid_pre <= ivalid;\n" #WN, testing for multi-cycle
                        . "end\n"
                        ;
                        
      }
      
      #reduction
      else {
      $str_ovalidLogic  .="always @(posedge clk) begin\n"
                        . "  if(rst)\n"
                        . "    ovalid_pre <= 1'b0;\n"
                        . "  else if (dontStall && (red_count==REDCOUNTLIMIT-1))\n"
                        . "    ovalid_pre <= 1'b1;\n"
                        . "  else\n" 
                        . "    ovalid_pre <= 1'b0;\n"
                        . "end\n"
                        ;
      }
      
      $str_ovalidLogic  .= "\//response to dontStall needs to be immediate, as I want to _halt_ the pipeline when there is a stall\n";
      
### >>>> synch debug      
      #when using multi-cycle stalling stubs 
        #(does not work with floats; why? <-- floats have their own branch for ovalid logic creation, look at that for debug
        # Gives correct results in integer HDL simulation when I inject stalls into the pipeline.
        # BUT hangs the hybrid simulation
        # UNLESS:: I add a special logic to the func_hdl_top module to ensure I keep getting ivalid even after
        #          input stream has ended (until the pipeline is flushed).
      $str_ovalidLogic  .= "\nassign ovalid = ovalid_pre & dontStall;\n";  
      
      #when using floats (or in general, without stalling nodes)
        #does NOT give correct results when I inject stalls in HDL only simulation.
        #BUT hybrid simulation (at least) completes.
      #$str_ovalidLogic  .= "\nassign ovalid = ovalid_pre;\n"; 
      
    }                      
    
  #now that port numbers and widhts are  known, generate code to instantiate and register them...
  my $str_inputports      = '';
  my $str_inputsregs      = '';
  my $str_resetbranch     = '';
  my $str_dontstallbranch = '';
  my $str_defaultbranch   = '';
  
  #loop though widths of all ports; if non-zero (i.e. exits), add code for it
  for (my $i = 1; $i<4; $i = $i+1) {
    if($portW[$i]) {
      my $w = $portW[$i];
      $str_inputports     .= "  , input      [$w-1:0]  in$i\n"; 
      $str_inputsregs     .= "reg [$w-1:0] in$i\_r;\n";
      $str_resetbranch    .= "    in$i\_r <= 0;\n";
      $str_dontstallbranch.= "    in$i\_r <= in$i;\n";
      $str_defaultbranch  .= "    in$i\_r <= in$i\_r;\n";
    }
  }
  chomp ($str_resetbranch    );
  chomp ($str_dontstallbranch);
  chomp ($str_defaultbranch  );
  
  
  #$secondOpInputPort = "  , input      [$portWop2-1:0]  in2_s0" if($portWop2); 
  #$thirdOpInputPort  = "  , input      [$portWop3-1:0]  in3_s0" if($portWop3); 

  
  $genCode  =~ s/<datapath>/$strBuf/g;
  $genCode  =~ s/<oStrWidth>/$oStrWidth/g;
  $genCode  =~ s/<inputports>/$str_inputports/g;
  $genCode  =~ s/<intputregs>/$str_inputsregs/g;
  $genCode  =~ s/<resetbranch>/$str_resetbranch/g;
  $genCode  =~ s/<dontstallbranch>/$str_dontstallbranch/g;
  $genCode  =~ s/<defaultbranch>/$str_defaultbranch/g;
  #$genCode  =~ s/<secondOpInputPort>/$secondOpInputPort/g;
  #$genCode  =~ s/<thirdOpInputPort>/$thirdOpInputPort/g;
  $genCode  =~ s/<inputIvalids>/$str_inputIvalids/g;
  #$genCode  =~ s/<inputReadys>/$str_inputIreadys/g; #replaced by a single iready output
  $genCode  =~ s/<inputIvalidsAnded>/$str_inputIvalidsAnded/g;
  $genCode  =~ s/<ireadysFanout>/$str_ireadysFanout/g;
  $genCode  =~ s/<assignConstants>/$str_assignConstants/g;
  $genCode  =~ s/<instFifoBuff>/$str_instFifoBuff/g;
  $genCode  =~ s/<ovalidLogic>/$str_ovalidLogic/g;
  $genCode  =~ s/<fpcEF>/$str_fpcEF/g;
  $strBuf   = "";
  $strBuf = "";
  
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
  
  print "TyBEC: Generated module $modName\n";  
} 


# ============================================================================
# GENERATE map node -- leaf -- multicycle stub
# ============================================================================
# to simulate multi-cycle behaviour, I am generating multi-cycle stubs

sub genMapNode_leaf_multicyclestub {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$hashref
      ,$vect
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  my $synthunit   = $hash{synthunit};
  my $synthDtype  = $hash{synthDtype};
  my $datat       = $synthDtype; #complete type (e.g i32)    
  (my $dataw = $datat)     =~ s/\D*//g; #width in bits
  (my $dataBase = $datat)  =~ s/\d*//g; #base type (ui, i, or float)
  my $fi = $hash{performance}{lfi};

  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);

  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName;
  $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.mapnode_leaf_multicyclestub.v";
  
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header and module name 
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;

  # -------------------------------------------------------
  # >>>>> DATAW/STREAMW parameters, and LATENCY
  # -------------------------------------------------------
  my $streamw;
  if($dataBase eq 'float')  {$streamw=$dataw+2;}
  else                      {$streamw=$dataw;}

  $genCode =~ s/<dataw>/$dataw/g;
  $genCode =~ s/<streamw>/$streamw/g;
  
  $genCode =~ s/<iterlat>/$fi/g;
  
  my $iterlatw = log2($fi);
  $genCode =~ s/<iterlatw>/$iterlatw/g;
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
  
  print "TyBEC: Generated module $modName\n";  
} 

# ============================================================================
# GENERATE map node -- hiearchical (functions)
# ==============================================5==============================

sub genMapNode_hier {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$dfgroup
      ,$hashref
      ,$vect  
      ,$top
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);
  my $strBuf = ""; # temp string buffer used in code generation 
  my $strBuf2 = ""; # temp string buffer used in code generation 

  # --------------------------------
  # >>>>> pndmap?
  # --------------------------------
  #my $pndmap = $hash{};
  
  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.mapnode_hier.v"; 
  #$templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.main.v" if ($dfgroup eq 'main');
  
  $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.main.v" if ($dfgroup eq 'main');
  
  #$templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.mapnode_hier.v" if ($dfgroup eq 'main');
      ## TODO/NOTE:: Doing this temporarilty as I had not committed the map template
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header, module name and parameter
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;
  
  #$strBuf = $dataw;
  #$genCode =~ s/<dataw>/$strBuf/g;
  #$strBuf = "";
  
  # -------------------------------------------------------
  # set latency
  # -------------------------------------------------------
  #now redundant as I dont have fixed latency kernels
  #my $lat = $main::CODE{main}{performance}{lat};
  #$genCode =~ s/<latency>/$lat/;  
  
  # -------------------------------------------------------
  # >>>>> dataw
  # -------------------------------------------------------
  my $datat; #complete type (e.g i32)
  my $dataw; #width in bits
  my $dataBase; #base type (ui, i, or float)
  
  if ($dfgroup eq 'main') {
    #TODO: I am using the data type of the first stream I see in main (connectd to global memory object) to set data type in main
    #but this is artificially limiting  
    #$strBuf = $dataw;
    foreach (keys %{$main::CODE{main}{symbols}} ) {
      if ($main::CODE{main}{symbols}{$_}{cat} eq 'streamread') {
        $datat = $main::CODE{main}{symbols}{$_}{dtype};
      }
    }
  } 
  else {
    $datat = $hash{synthDtype};
  }
  
  #extract base type and width
  ($dataw = $datat)     =~ s/\D*//g;
  ($dataBase = $datat)  =~ s/\d*//g;
  
  #record the scalar width as dataw may be scaled up by the vectorization factor
  my $scalarw = $dataw;
  
  #scale dataw by the vectorization factor (should only happen in case the module is the top one)
  
  $dataw = $dataw * $vect;
    
  #set stream width, +2 for floating types (for comp with flopoco)
    #but dont add in main, as we explicitly add/remove these 2 bits in main for upwards 32-bit compatibility
  my $streamw;
  if(($dataBase eq 'float') && ($dfgroup ne 'main')) {$streamw=$dataw+(2*$vect); $scalarw = $scalarw+2;}
  else                                               {$streamw=$dataw;}
  
  $genCode =~ s/<dataw>/$dataw/g;
  $genCode =~ s/<streamw>/$streamw/g;
  $genCode =~ s/<scalarw>/$scalarw/g;
  
  # -------------------------------------------------------
  # >>>>> 
  # -------------------------------------------------------
  #string buffers for creating code for different parts of the template
  my $strPorts      = "";
  my $strInsts      = "\n// Instantiations\n";
  my $strConns      = "\n// Data and control connection wires\n";
  my $str_extractFloatData = "";
  my $str_ovalids   = "";
  my $str_ireadysAnd= "";
  my $str_ivalids   = "";
  my $str_oreadys   = "";
  my $str_ivalidsAnd= "assign ivalid = 1'b1\n";
  my $str_oreadysAnd= "assign oready = 1'b1\n";
  my $str_ireadyConns= "";
  my $excFieldFlopoco='';
  my $flPre='';
  my $flPst='';  
  # -------------------------------------------------------
  # >>>>> prepend flopoco control bits if main
  # -------------------------------------------------------
  my $iAmMainAndFloating = (($dataBase eq 'float') && ($dfgroup eq 'main'));
  if($iAmMainAndFloating) {
    $excFieldFlopoco = 
     "//Exception fields for flopoco                                         \n"
    ."//A 2-bit exception field                                              \n"
    ."//00 for zero, 01 for normal numbers, 10 for infinities, and 11 for NaN\n"
    ."wire [1:0] fpcEF = 2'b01;                                              \n";
    $flPre = '{fpcEF,';
    $flPst = '}';
  }
  
  
  #Loop through all connected groups till you get to  group against this function
  my @nodes_conn = $main::dfGraph->weakly_connected_components();
  foreach (@nodes_conn) { 
    my @conn_group_items = @{$_};
    my ($dfg, undef) = split('\.',$conn_group_items[0],2); 
    
    #we are at the connected group for this function \
    ##TODO: If it is truly distributed, I shouldnt need to call to do this... I will have a single call that creates RTL for ALL modules
    if($dfg eq $dfgroup) { 
      #---------------------------------------------------------------------
      # INSTANTIATIONS
      #---------------------------------------------------------------------
      #a local hash to keep track of IREADYs that need to be collected (anded) 
      #applies to a oneProducerOneSignal-to-manyConsumer scenario
      my %iReadyHash;
      
      #I use the token list to find all nodes in this function as I may have disconected graphs 
      #(so can't use "find weakly connected" approach to identify nodes belonging to a function
      foreach my $symbol (keys $main::CODE{$dfgroup}{symbols}) {
        #my $parentFunc= $main::dfGraph -> get_vertex_attribute ($item, 'parentFunc');
        #my $symbol    = $main::dfGraph -> get_vertex_attribute ($item, 'symbol'    ); #already available from hash key

        #"item" should refer to the identifier in the _DFG_
        my $item = $dfgroup.".".$symbol;
        my $parentFunc= $dfgroup;
        
        (my $ident =  $symbol) =~ s/(%|@)//; #remove %/@
        my $cat       = $main::CODE{$parentFunc}{symbols}{$symbol}{cat};
        my $redSize   = -1;
        $redSize = $main::CODE{$parentFunc}{symbols}{$symbol}{reductionSize} 
          if (defined $main::CODE{$parentFunc}{symbols}{$symbol}{reductionSize});
        
        #---------------------------------
        #ports
        #---------------------------------
        #+ If any node is vectorized (and current policy is to only vectorize `top`), then my rule is to:
        #+ Always have coalesced IO ports for that module
        #+ Slicing and packing happens inside the module being vectorized
        
        if(($cat eq 'arg') || ($cat eq 'func-arg')) {
          my $dir =  $main::CODE{$parentFunc}{symbols}{$symbol}{dir};
          $strPorts .= "\n, $dir"." [STREAMW-1:0]  $ident\n";#."_s$i\n";
          
          #create input valids from all inputs, and AND them together:
          if($dir eq 'input') {
            $str_ivalids     .= "  , input ivalid_$ident\n"; 
            $str_ivalidsAnd  .= "  & ivalid_$ident\n";
          }
          
          #create output readys from all outputs, and AND them together:
          if($dir eq 'output') {
            $str_oreadys     .= "  , input oready_$ident\n"; 
            $str_oreadysAnd  .= "  & oready_$ident\n";
          }
          #}#else
        }#if
        
        #incase of main, it can be alloca port as well
        #TODO: direction should be picked up from the edge, not the alloca node, since there can be multiple streams (both in an out)
        #from the same alloca object
        if($cat eq 'alloca') {
          #loop over all stream connections from this alloca object
          foreach my $key (keys %{$main::CODE{$parentFunc}{symbols}{$symbol}{streamConn}}) {
            my $dir  =  $main::CODE{$parentFunc}{symbols}{$symbol}{streamConn}{$key}{dir};
            my $name =  $main::CODE{$parentFunc}{symbols}{$symbol}{streamConn}{$key}{name};
            $name =~ s/(@|%)//;
            
            #if main, then my vectorized data wires are packed into a single bus
            if($dfgroup eq 'main') {
              $strPorts  .= "\n  , $dir"." [STREAMW-1:0]  $name\n";
            }
            #if not, the vector elements are separately available <-- is this redundant? Do I ever have alloca inside non-main functions?
            else {
              for (my $i=0; $i<$vect; $i++) {
                $strPorts .= "\n  , $dir"." [STREAMW-1:0]  $name"."_s$i\n";
              }#for
            }
           #push the port onto  hash for later use (in OCL code generation, required for main only)
           $main::CODE{$parentFunc}{allocaports}{$name}{dir} = $dir;
          }
        }
        
        #-----------------------------
        #instantion of child modules
        #-----------------------------
        if( ($cat eq 'impscal') 
          ||($cat eq 'func-arg') 
          ||($cat eq 'funcall')
          ||($cat eq 'fifobuffer')
          ||($cat eq 'smache')
          ||($cat eq 'autoindex')
          ){
          #remove _N from identity of funcall instructions
          #$ident =~ s/\.\d+// if($cat eq 'funcall');
          $ident =~ s/\_\d+$// if($cat eq 'funcall');

          #name of module to instantiate
          my $module2Inst = $parentFunc."_".$ident;
          
          #is this a pndmap module (in which case instantiate wrapper)
          my $pndmap = 1;
          $pndmap =  $main::CODE{$parentFunc}{symbols}{$symbol}{pndmap}
            if (exists ($main::CODE{$parentFunc}{symbols}{$symbol}{pndmap}));

          #==================================
          for (my $v=0; $v<$vect; $v++) {
          #==================================
            #convenience booleans
            my $atomic         = (($cat eq 'smache') || ($cat eq 'autoindex'));
            my $atomicNotS0    = (($v!=0)       && $atomic);
            my $atomicS0       = (($v==0)       && $atomic);
            my $atomicNotSLast = (($v!=$vect-1) && $atomic);
            
            #the suffix added to various signals depends on whether or not this a potentially vectorizable module
            #in the current approach, only top can be vectorized
            my $vsuff = '';
            $vsuff = "_s$v" if ($top);
            
            $module2Inst .= "_pndmapWrapper" if ($pndmap > 1);
            my $modInstanceName = $atomic ? $module2Inst."_i" : $module2Inst."_i$vsuff";
              
            #if I need to extract scalar from packed vector, what are the hi/lo bits
            my $lo = $v*$scalarw;
            my $hi = ($v+1)*$scalarw-1;
          #-----------------------------------------
            #common control signals
            $strInsts = $strInsts."\n"
                      . "$module2Inst \n"
#                      . "#()\n"
                      . "$modInstanceName (\n"
                      . "  .clk    (clk)\n" 
                      . ", .rst    (rst)\n" 	
                      unless $atomicNotS0;
                      
            #connections -- func-args
            #-----------------------
            #if $item is a func-arg (a compute node that is also an argument), it needs 
            #outport data and connections that are not exposed by the edges
            #(because it has no "consumer")
            #Does not apply if reduction argument though, as it DOES have a consumer then (itself)
            if (($cat eq 'func-arg') && ($redSize<0)){
            #if (($cat eq 'func-arg')){
              my $dir =  $main::CODE{$parentFunc}{symbols}{$symbol}{dir};
              #$strInsts .= ", .out1  ( $ident$vsuff)\n"; 
              $strInsts .= ", .out1  ( $ident\[$hi:$lo\])\n"; 
              
              if($dir eq 'output') {
                #ovalid for this func-arg is used to create the global ovalid
                #and since this is a terminal node, it is fed the global oready
                $strInsts.= ", .ovalid (ovalid_$ident$vsuff)\n"
                          . ", .oready (oready)\n"
                          ;    
                #each generated module for a vector element has its own ovalid
                $strConns .= "\nwire ovalid_$ident$vsuff;";
                $str_ovalids .= "        ovalid_$ident$vsuff &\n";
              }
            }
            
            #connections -- outputs
            #-----------------------
            my @succs = $main::dfGraph->successors($item);
            foreach my $consumer (@succs) {
              #Loop over multi-edges (that is, multiple wires between prod and cons)
              #if applicable
              my @multiedges = $main::dfGraph->get_multiedge_ids($item, $consumer);
              foreach my $id (@multiedges) {
                #get edge properties
                my $connection  = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'connection' );
                my $pnode_pos   = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'pnode_pos'  );
                my $cnode_pos   = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'cnode_pos'  );
                my $pnode_local = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'pnode_local');
                my $cnode_local = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'cnode_local');
                my $pnode_cat   = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'pnode_cat'  );
                my $cnode_cat   = $main::dfGraph ->get_edge_attribute_by_id ( $item, $consumer, $id, 'cnode_cat'  );
                $connection =~ s/(%|@)//; 
                
                #atomic modules have vectorization suffixes on internal ports, so it requires a separate suffix variable
                my $vsuff4atomics = '';
                $vsuff4atomics = "_s$v" if (($pnode_cat eq 'smache') || ($pnode_cat eq 'autoindex')) ;
                
                #condition variable indicating consumer is a port (not an imp-scalar or a func-call)
                my $consumerisPort = ( ($cnode_cat eq 'arg') 
                                      
                                    || ($cnode_cat eq 'alloca') 
                                    || ($cnode_cat eq 'streamread') 
                                    || ($cnode_cat eq 'streamwrite')
                                    ); #redundant?
                                    #|| ($cnode_cat eq 'func-arg')
                                      #func-arg not included in this category as unlike a reguler arg, it
                                      #instantiates a module, so the connection rules that apply to a "module" 
                                      #apply here too
                                    
                #condition variable indicating consumer is a module (will require explicitly declated connection wires)
                my $consumerisModule  =  ($cnode_cat eq 'impscal') 
                                      || ($cnode_cat eq 'func-arg') 
                                      || ($cnode_cat eq 'funcall') 
                                      || ($cnode_cat eq 'fifobuffer') 
                                      || ($cnode_cat eq 'smache') 
                                      ;
                #condition indicating producer is node, as node modules have different port naming
                #conventions (single oready, named "oready")
                my $producerisLeafNode =  ($pnode_cat eq 'impscal')
                                       || ($pnode_cat eq 'fifobuffer')
                                       ;            
                                       
                my $producerisBuffer =  ($pnode_cat eq 'fifobuffer');
                                     
                my $producerisAutoindex = ($pnode_cat eq 'autoindex');
                
                my $producerisAtomic =  ($pnode_cat eq 'autoindex')
                                     || ($pnode_cat eq 'smache')
                                     ;

                #vectorization suffixes only needed if top
                #ports are slices, other wires are suffixed with "_sV"
                if ($top){
                  if ($consumerisPort) {$connection = $connection."[$hi:$lo]";}
                  else                 {$connection = $connection."_s$v";}
                }

                #data port connection 
                #if main and floating, then I am instanitating top, which emits data preprended with flopoco control bits
                #interleaved at scalar level inside vector words. So I assign to local variable and then extract data 
                if($iAmMainAndFloating) {
                  my $vect = $main::ioVect;
                  my $streamW_withControl = $vect * ($scalarw + 2); #2 extra bits per scalar
                  $str_extractFloatData .= "wire [$streamW_withControl-1:0] $connection\_WC;\n";
                  
                  #extract data from each word
                  foreach my $vvv(reverse 0 .. $vect-1){
                    #hi and lo bit, with and without control bits interleaved
                    my $lolo_wc = $vvv*($scalarw+2);
                    my $hihi_wc = ($vvv+1)*($scalarw+2)-1;                    
                    my $lolo    = $vvv*$scalarw;
                    my $hihi    = ($vvv+1)*$scalarw-1;
                    
                    $str_extractFloatData .= "assign $connection\[$hihi:$lolo\] =  $connection\_WC\[$hihi_wc:$lolo_wc\];\n";
                  }
                  $strInsts   .= ", .$pnode_local$vsuff4atomics ( $connection\_WC )\n";
                }
                else {
                  $strInsts   .= ", .$pnode_local$vsuff4atomics ( $connection )\n";
                }
                
                #the consumer-side axi signal connections (and requirement of explicit connection wires)
                #depend on whether consumer is a another module instance, or direct connection to parent port
                my $app = '';
                #if ($consumerisModule) {
                if (($consumerisModule) && ($redSize<0)){
                  #data wire only instantiated the node is not reducing
                  #otherwise, that data wire is already available as "output" (and used as input internally)
                  if ($redSize<0) { #and not reducint
                    #connection wires
                    $strConns .= "\nwire [SCALARW-1:0]  $connection;";
                  }#not reducing

                  #valid signal is named after _module_, not the _connection_, as every module has a _single_ ovalid
                  #which should be used for ALL consumers. See NOTES, 2017.07.15
                  #$strConns .= "\nwire valid_$connection;"; 
                  $strConns .= "\nwire valid_$ident$vsuff;"; 
                  $strConns .= "\nwire ready_$connection;";
                  
                  #control port connetions
                  #if producer is fifobuffer, it can have multiple ovalids per data output(this is the only case)
                  $app = "_$pnode_local"    if $producerisBuffer;
                  #If atomic node, then output valids will have vectorization suffix
                  $app = "$vsuff4atomics"  if $producerisAtomic;
                  
                  $strInsts .= ", .ovalid$app (valid_$ident$vsuff)\n";
                  
                  #oready 
                  #------
                  #is named differently depending on whether or not producer is a leaf node
                  #as leaf nodes have a single oready named "oready"
                  #also, autoindex do not have oreadys
                  $app = '';
                  if ($producerisLeafNode) {
                    #if producer is fifobuffer or smache, it can have multiple oreadys (this is the only case)
                    #so the ovalids are appended with relevant output data identifieer
                    #Also: vectorization suffix only for smache, not for plain buffers
                    
                    $app = "_$pnode_local"  if $producerisBuffer;
                    $app = "$vsuff4atomics" if $producerisAtomic;
                    $strInsts .=  ", .oready$app (ready_$connection)\n";
                    #TODO: if multiple consumers for this leaf node, then the single OREADY
                    #has to be distributed across nodes
                  }
                  elsif ($producerisAutoindex) {
                    $strInsts .= '';
                  }
                  #consumer is not a module
                  else {
                    $strInsts .=  ", .oready_$pnode_local$vsuff4atomics (ready_$connection)\n";}
                }#if consumerisModule
                
                #consumer is parent port, or this is a reduction func-arg output port
                #so the ovalid from the producer should be used to create the global ovalid
                else {
                  $strConns   .= "\nwire ovalid_$ident$vsuff;";
                  $str_ovalids.= "        ovalid_$ident$vsuff &\n";
                  $strInsts   .=", .ovalid (ovalid_$ident$vsuff)\n";
                  #if reduction func-arg port, then oready named differently as this is no 
                  #longer a direct port connection requiring a local wire
                  #but a connection to a leaf nodes oready, which has no suffixex
                  if($redSize < 1) {$strInsts   .=", .oready_$pnode_local (oready)\n";}
                  else             {$strInsts   .=", .oready (oready)\n";}
                }
                
                
                #autoindex requires special treatment, as it does not have a predecessor
                #so it is only a consumer. We need to find the right trigger for it
                if ($pnode_cat eq 'autoindex'){
                
                  my $trigger;
                  #this is nested _over_ another counter, so input trigger is output wrap trigger 
                  #of that counter.
                  if (exists $main::CODE{$parentFunc}{symbols}{$symbol}{nestOver}) {
                    my $nestOver = $main::CODE{$parentFunc}{symbols}{$symbol}{nestOver};
                    my $nestOverConn = $main::CODE{$parentFunc}{symbols}{$nestOver}{produces}[0];
                    $nestOverConn =~ s/(%|@)//;
                    $trigger = "trig_wrap_$nestOverConn$vsuff";
                  }
                  else {
                    #find the source stream for creating the autoindex
                    #then find it's VALID (whose name depends on whether or not is an  input arg)
                    #to use as trigger
                    my $sstream = $main::CODE{$parentFunc}{symbols}{$symbol}{sstream};
                    my $sstream_cat = $main::CODE{$parentFunc}{symbols}{$sstream}{cat};
                    $sstream =~ s/(%|@)//; 
                    if ($sstream_cat eq 'arg')  {$trigger = "ivalid";}
                    else                        {$trigger = "valid_$sstream$vsuff";}
          
                  }
                  #connect with the identified trigger
                  $strInsts .=  ", .trig_count$vsuff4atomics ($trigger) \n";
                  
                  #create and connect to output wrap trigger signal
                  $strConns .= "\nwire trig_wrap_$connection;";
                  $strInsts .=  ", .trig_wrap$vsuff4atomics  (trig_wrap_$connection) \n";
                  
                  #autoindex always connects to GLOBAL ivalid
                  $strInsts .=  ", .ivalid$vsuff4atomics  (ivalid) \n";
                }
              }#foreach my $id (@multiedges) {
            }#foreach consumer
            
            
            #connections -- inputs
            #-----------------------
            my @preds = $main::dfGraph->predecessors($item);
            foreach my $producer (@preds) {
              
              #get producer identifier (it's name in the DFG graph is quite mangled)
              my $psymbol    = $main::dfGraph -> get_vertex_attribute ($producer, 'symbol'    );
              (my $pident =  $psymbol)  =~ s/(%|@)//; #remove %/@
              $pident                   =~ s/\_\d+$//; #remove _N subscript
              
              #Loop over multi-edges, if applicable
              my @multiedges = $main::dfGraph->get_multiedge_ids($producer, $item);
              foreach my $id (@multiedges) {
                #get edge properties
                my $connection  = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'connection' );
                my $pnode_pos   = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'pnode_pos'  );
                my $cnode_pos   = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'cnode_pos'  );
                my $pnode_local = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'pnode_local');
                my $cnode_local = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'cnode_local');
                my $pnode_cat   = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'pnode_cat'  );
                my $cnode_cat   = $main::dfGraph ->get_edge_attribute_by_id ($producer, $item, $id, 'cnode_cat'  );
                
                #condition variable indicating producer a port (not another peer function)
                my $producerisPort = ( ($pnode_cat eq 'arg') 
                                    || ($pnode_cat eq 'alloca') 
                                    || ($pnode_cat eq 'streamread') 
                                    || ($pnode_cat eq 'streamwrite')
                                    );

                my $producerisModule =  ($pnode_cat eq 'impscal') 
                                     || ($pnode_cat eq 'func-arg') 
                                     || ($pnode_cat eq 'funcall')                                    
                                     || ($pnode_cat eq 'fifobuffer')                                    
                                     || ($pnode_cat eq 'smache')                                    
                                     || ($pnode_cat eq 'autoindex')                                    
                                     ;
                                     

                $connection =~ s/(%|@)//; 

                #smache module has vectorization suffixes on internal ports, so it requires a separate suffix variable
                my $vsuff4atomics = '';
                $vsuff4atomics = "_s$v" if (($cnode_cat eq 'smache') || ($cnode_cat eq 'autoindex')) ;
                
                #vectorization suffixes only if top 
                if ($top){
                  if ($producerisPort) {$connection = $connection."[$hi:$lo]";}
                  else                 {$connection = $connection."_s$v";}
                }
                
                #if this a reduction node, and this "predecessor" is this node itself, then no connections for this port
                if ($pident eq $ident) {
                } 

                #not a reduction node, make input connection
                else {
                  #if this is main + floating data, then I need  to prepend flopoco control bits when instantiating TOP
                  #This prepend operation has to be interleaved inside the vector word
                  if($iAmMainAndFloating) {
                    $strInsts   .= ", .$cnode_local$vsuff4atomics ( {";
                    
                    my $vect = $main::ioVect;
                    foreach my $vvv(reverse 0 .. $vect-1){
                      my $lolo = $vvv*$scalarw;
                      my $hihi = ($vvv+1)*$scalarw-1;                    
                      $strInsts   .= "fpcEF, $connection\[$hihi:$lolo\], ";
                    }
                    chop($strInsts);
                    chop($strInsts);
                    $strInsts   .= "})\n";
                  }
                  else {
                    $strInsts   .= ", .$cnode_local$vsuff4atomics ($connection)\n";
                  }
                   
                  #each generated module for a vector element has its own iready
                  $strConns   .= "\nwire iready_$ident$vsuff;  \n";
                  
                  #$str_ireadysAnd = $str_ireadysAnd."        iready_$ident"."_s$v &\n";
                  #if producer is port (so this is first stage node), then use it to create the global IREADY
                  $str_ireadysAnd .= "        iready_$ident$vsuff &\n" if ($producerisPort);

                  #atomic nodes (smache) do not use local node's identify for controls at input, as
                  #they are guaranteed to have either single input, or sychronized vector inputs
                  my $cnode_local_suff = "_$cnode_local";
                  $cnode_local_suff = '' if $atomic;
                  
                  #the producer-side axi signal connections (and requirement of explicit connection wires)
                  #depend on whether producer is a another module instance, or direct connection to parent port
                  if ($producerisModule) {
                    #connection wires
                    $strConns .= "\nwire [SCALARW-1:0]  $connection;";
                    #valid signal is names after _module_, not the _connection_, as every module has a _single_ ovalid
                    #which should be used for ALL consumers. See NOTES, 2017.07.15                  
                    #$strConns .= "\nwire valid_$connection;";
                    $strConns .= "\nwire valid_$pident$vsuff;";
                    $strConns .= "\nwire ready_$connection;";
                    
                    #port connetions
                    #we  have IVALID for EACH input port
                    #IREADY is common for node
                    #$strInsts .= ", .ivalid_$cnode_local"."_s$v (valid_$connection)\n"
                    #$strInsts .= ", .ivalid_$cnode_local"."_s$v (valid_$pident)\n"
                    $strInsts .= ", .ivalid$cnode_local_suff$vsuff4atomics (valid_$pident$vsuff)\n"
                              .  ", .iready$vsuff4atomics (iready_from_$ident$vsuff)\n"
                              ;
                    #manyproducers-to-oneconsumer                            
                    #a single, common iready is now fed to each predecessor's oready...
                    #make those connections (glue logic) here (simple fan-out)
                    $str_ireadyConns .= "wire iready_from_$ident$vsuff;\n";
                    #$str_ireadyConns .= "assign ready_$connection = iready_from_$ident;\n";
                    #$str_ireadyConns .= "ready_$connection &= iready_from_$ident;\n";
                    
                    #oneproducer-to-manyconsumers
                    #collect iready into hash, generate later
                    push @{$iReadyHash{"ready_$connection"}}, "iready_from_$ident$vsuff";
                  }#if
                  #producer is port; 
                  #ivalid connects directly to parent ivalid
                  #iready connects to local wire (which is ANDED to produce a global IREADY)
                  else {
                    #$strInsts   .=", .ivalid_$cnode_local"."_s$v (ivalid)\n"
                    $strInsts   .=", .ivalid$cnode_local_suff$vsuff4atomics (ivalid)\n"
                                . ", .iready$vsuff4atomics (iready_$ident$vsuff)\n"
                                ;    
                  }#producer is not module
                }#else (when not a reduction) 
              }#foreach my $id (@multiedges) {
            }#foreach -- input connections
            
            #complete 
            $strInsts .= "\n);\n" unless $atomicNotSLast;
            
            #this has to happen here as instantiations of different modules may legitimately have identical lines
            $strInsts = $strInsts."\n"
                      . "<instantiations>";
            remove_duplicate_lines($strInsts); 
            $genCode  =~ s/<instantiations>/$strInsts/g;
            $strInsts = "";
          }#for (my $v=0; $v<$vect; $v++) {
        }#if(($cat eq 'impscal') || ($cat eq 'func-arg') || ($cat eq 'funcall')) {
      }#foreach node  

      #after looping over all inputs of all nodes, now go through the iReady hash and 
      #create all ready signals
      #See NOTES, for date: 2019.06.07 (or thereabout)
      foreach my $readyConns (keys %iReadyHash) {
        #make sure each connection in the list against this hash (ready connection wire) is unique
        #duplications arise as the same connection is made from both prod and cons p.o.v.
        my %hash = map {$_,1} @{$iReadyHash{$readyConns}};
        my @readyConnsUniq = keys %hash;

        #now generate first list of assigment, then loop over connections to and them into a single
        #iready that should go to all predecessors        
        $str_ireadyConns .= "assign $readyConns = 1'b1 ";        
        foreach (@readyConnsUniq) {
          $str_ireadyConns .= "& $_";
        }
        $str_ireadyConns .= ";\n";
      } 
      
      #close IVALIDS and OREADY anding string
      $str_ivalidsAnd .= "  ;\n";
      $str_oreadysAnd .= "  ;\n";

   
      #remove any duplicate wire/port declarations (created due to fanout)
      #See: http://www.regular-expressions.info/duplicatelines.html
      #$strPorts=~ s/^(.*)(\r?\n\1)+$/$1/mg;
      #$strInsts=~ s/^(.*)(\r?\n\1)+$/$1/mg;
      #$strConns=~ s/^(.*)(\r?\n\1)+$/$1/mg;
      
      remove_duplicate_lines($strPorts);
      remove_duplicate_lines($strConns);
      remove_duplicate_lines($str_extractFloatData);
      remove_duplicate_lines($str_ovalids);
      remove_duplicate_lines($str_ireadysAnd);
      remove_duplicate_lines($str_ivalidsAnd);
      remove_duplicate_lines($str_oreadysAnd);
      remove_duplicate_lines($str_ireadyConns);
      
      $genCode  =~ s/<ports>/$strPorts/g;
      $genCode  =~ s/<connections>/$strConns/g;
      $genCode  =~ s/<extractFloatData>/$str_extractFloatData/g;
      $genCode  =~ s/<ovalids>/$str_ovalids/g;
      $genCode  =~ s/<ireadysAnd>/$str_ireadysAnd/g;
      $genCode  =~ s/<ivalids>/$str_ivalids/g;
      $genCode  =~ s/<ivalidsAnd>/$str_ivalidsAnd/g;
      $genCode  =~ s/<oreadys>/$str_oreadys/g;
      $genCode  =~ s/<oreadysAnd>/$str_oreadysAnd/g;
      $genCode  =~ s/<ireadyConns>/$str_ireadyConns/g;
      $genCode  =~ s/<excFieldFlopoco>/$excFieldFlopoco/g;      
      $genCode  =~ s/<instantiations>//g;
      $strPorts = "";
      $strInsts = "";
      $strConns = "";
    }
  }
  
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
  
  print "TyBEC: Generated module $modName\n";  
} 


# ============================================================================
# GENERATE map node -- hiearchical (functions)
# ==============================================5==============================

sub genPndmapWrapper {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$dfgroup
      ,$hashref
      ,$vect      
      ,$pndmap      
      ) = @_; 
      
  my %hash        = %{$hashref};  #the hash from parsed code for this pipe function
  
  #Vectorization suffix
  my $vsuff = '';
  #my $vsuff = "_s$i"; #obsolete; revive if I ever consider isolated vectorization of leaf nodes
  
  
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);

  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.pndmapWrapper.v"; 
  #$templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.main.v" if ($dfgroup eq 'main');
  
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;

  # --------------------------------
  # >>>>> Update header, module name and parameter
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;
   
  # -------------------------------------------------------
  # >>>>> dataw, thread counter width
  # -------------------------------------------------------
  my $datat; #complete type (e.g i32)
  my $dataw; #width in bits
  my $dataBase; #base type (ui, i, or float)
  
  if ($dfgroup eq 'main') {
    #TODO: I am using the data type of the first stream I see in main (connectd to global memory object) to set data type in main
    #but this is artificially limiting  
    #$strBuf = $dataw;
    foreach (keys %{$main::CODE{main}{symbols}} ) {
      if ($main::CODE{main}{symbols}{$_}{cat} eq 'streamread') {
        $datat = $main::CODE{main}{symbols}{$_}{dtype};
      }
    }
  } 
  else {
    $datat = $hash{synthDtype};
  }
  
  #extract base type and width
  ($dataw = $datat)     =~ s/\D*//g;
  ($dataBase = $datat)  =~ s/\d*//g;
  
  #set stream width, +2 for floating types (for comp with flopoco)
    #but dont add +s in main, as we explicitly add/remove these 2 bits in main for upwards 32-bit compatibility
  my $streamw;
  if(($dataBase eq 'float') && ($dfgroup ne 'main')) {$streamw=$dataw+2;}
  else                                               {$streamw=$dataw;}
 
  $genCode =~ s/<dataw>/$dataw/g;
  $genCode =~ s/<streamw>/$streamw/g;
  
  my $th_rr_counter_w = log2($pndmap);
  $genCode =~ s/<th_rr_counter_w>/$th_rr_counter_w/g;
 
  # -------------------------------------------------------
  # >>>>> 
  # -------------------------------------------------------
  #string buffers for creating code for different parts of the template
  my $strPorts          = "";
  my $strInsts          = "\n// Instantiations\n";
  my $strConns          = "\n// Data and control connection wires\n";
  my $str_ovalids       = "";
  my $str_ireadysAnd    = "";
  my $str_ivalids       = "";
  my $str_oreadys       = "";
  my $str_ivalidsAnd    = "assign ivalid = 1'b1\n";
  my $str_oreadysAnd    = "assign oready = 1'b1\n";
  my $str_ireadysOr     = "assign iready = 1'b0\n";
  my $str_ireadyConns   = "";
  my $str_demux         = '';
  my $str_mux           = '';
  my $str_mux_def       = '';
  my $str_ovalidsConcat = '';
  my $str_instances     = '';
    
  #Loop through all connected groups till you get to  group against this function
  my @nodes_conn = $main::dfGraph->weakly_connected_components();
   
  my $dfgroupDone = 0;
  foreach (@nodes_conn) { 
    my @conn_group_items = @{$_};
    my ($dfg, undef) = split('\.',$conn_group_items[0],2); 
    
    
    
    #we are at the connected group for this function
    if(($dfg eq $dfgroup) && ($dfgroupDone == 0)){
      #we want to make sure we generate code for this dfg group only once
      #this needs to be ensured as otherwise disconnected graphs in a module can cause
      #the same logic to be genereated multiple times
      $dfgroupDone = 1;
      my %iReadyHash;
     
      #---------------------------------
      #Loop through all threads, gen code
      #---------------------------------
      $genCode =~ s/<nthreads>/$pndmap/g;
      (my $module2Inst = $modName) =~ s/_pndmapWrapper$//;
      
      #all ovalids are concatenated for convenience at mux input
      #since mux expects ovalids of threads numbered in descending order, we count down only for them
      for (my $t=$pndmap-1; $t>=0; $t = $t-1){      
        $str_ovalidsConcat.= "ovalid_t$t,";
      }
      
      #count UP through all threads, generating code for each
      for (my $t=0; $t<$pndmap; $t = $t+1){      
        #all iready's are ORRED to create the global iready, as parent ready if ANY child ready
        $str_ireadysOr    .= "  | iready_t$t\n";
        
        #create instance for this thread
        $str_instances = $str_instances."\n"
                      . "$module2Inst \n"
                      . "$module2Inst"."_t$t (\n"
                      . "  .clk    (clk)\n" 
                      . ", .rst    (rst)\n" 	
                      . ", .ovalid (ovalid_t$t)\n"
                      . ", .iready (iready_t$t)\n"
                      ; 
        #start demux entry for this thread
        $str_demux.= "    $th_rr_counter_w\'d$t: begin\n";
              
        #things to do per argument, per thread
        #I use the token list to find all nodes in this function as I may have disconected graphs
        foreach my $symbol (keys $main::CODE{$dfgroup}{symbols}) {
          #"item" should refer to the identifier in the _DFG_
          my $item = $dfgroup.".".$symbol;
          
          #foreach my $item (@conn_group_items) {
        
          my $parentFunc= $main::dfGraph -> get_vertex_attribute ($item, 'parentFunc');
          my $symbol    = $main::dfGraph -> get_vertex_attribute ($item, 'symbol'    );
          (my $ident =  $symbol) =~ s/(%|@)//; #remove %/@
          my $cat       = $main::CODE{$parentFunc}{symbols}{$symbol}{cat};
          
          if(($cat eq 'arg') || ($cat eq 'func-arg')) {
            my $dir =  $main::CODE{$parentFunc}{symbols}{$symbol}{dir};
            $str_instances .= ", .$ident ($ident\_t$t)\n";
            
            #create data ports, input and output
            for (my $i=0; $i<$vect; $i++) {
              my $regornot; #is the port a reg (output) or not
              $regornot = ''    if ($dir eq 'input');
              $regornot = 'reg' if ($dir eq 'output');
              
              $strPorts .= "\n"
                      ."  , $dir"." $regornot [STREAMW-1:0]  $ident$vsuff\n"
                      ;
            }#for
            
            #------------------------
            if($dir eq 'input')  {
            #------------------------
              $str_instances  .=", .ivalid_$ident (ivalid_$ident\_t$t)\n";              
              $str_ivalids    .= "  , input ivalid_$ident\n"; 
              $str_ivalidsAnd .= "  & ivalid_$ident\n";
              
              #per ndmap thread wires, and demux connections (input)
              #for my $t(0..$pndmap-1){
              $strConns .= "reg  [STREAMW-1:0]  $ident\_t$t        ;\n"
                        .  "reg                 ivalid_$ident\_t$t ;\n"
                        .  "wire                iready_t$t         ;\n"
                        ;
                          
              #each thread has its CASE, and then within that
              #we iterate through all threads _again_, assigning data to current thread
              #and setting others to zero
              for my $tt(0..$pndmap-1){
                #assign data only to _current_ thread t
                if($t == $tt) {
                  $str_demux.= "      ivalid_$ident\_t$tt = ivalid; \n"
                            .  "      $ident\_t$tt        = $ident;\n"
                            ;
                }
                else {
                  $str_demux.= "      ivalid_$ident\_t$tt = 0;\n"
                            .  "      $ident\_t$tt        = 0;\n"
                            ;
                }
              }#for
            }#if
            
            #------------------------
            if($dir eq 'output') {
            #------------------------
              $str_instances .=", .oready_$ident (oready)\n";
              $str_oreadys   .="  , input oready_$ident\n"; 
              $str_oreadysAnd.="  & oready_$ident\n";
              $strConns       .= "wire [STREAMW-1:0]  $ident\_t$t ;\n"
                              .  "wire                ovalid_t$t  ;\n"
                              ;
              
              #each thread has its CASE
              #current case's bit stream (one-shot encoding)
              my $ccb = oneshot($t,$pndmap);
              #$ccb = '';#oneshot($t,$pndmap);
              
              $str_mux .="    $pndmap\'b$ccb   : begin \n"
                       . "      ovalid = ovalid_t$t;   \n"
                       . "      $ident = $ident\_t$t;\n"
                       ;
              #close default branch in mux, sep location in the code required diff tag
              $str_mux_def  .=  "      $ident = 0; \n";
            }#if output
          }#if arg or func-arg
        }#foreach item
        
        $str_mux  .=  "    end  //$t\n";
        $str_demux.=  "    end\n";
        $str_instances .= ");\n";
      }#for t in pndmap
      chop($str_ovalidsConcat);
    }#if
  }#foreach

  #close IVALIDS and OREADY anding string
  $str_ireadysOr  .= "  ;\n";
  $str_ivalidsAnd .= "  ;\n";
  $str_oreadysAnd .= "  ;\n";
      
  remove_duplicate_lines($strPorts);
  remove_duplicate_lines($strConns);
  remove_duplicate_lines($str_ovalids);
  remove_duplicate_lines($str_ireadysAnd);
  remove_duplicate_lines($str_ivalidsAnd);
  remove_duplicate_lines($str_oreadysAnd);
  remove_duplicate_lines($str_ireadyConns);
  remove_duplicate_lines($str_ivalids  );  
  remove_duplicate_lines($str_oreadys  );  
  remove_duplicate_lines($str_mux_def  );  
  remove_duplicate_lines($str_mux  );  
  
  #remove_duplicate_lines($str_instances);  
  #remove_duplicate_lines($str_demux        );
  #remove_duplicate_lines($str_mux          );
  #remove_duplicate_lines($str_mux_def      );
  #remove_duplicate_lines($str_ovalidsConcat);
  
  
  $genCode  =~ s/<ports>/$strPorts/g;
  $genCode  =~ s/<connections>/$strConns/g;
  $genCode  =~ s/<ovalids>/$str_ovalids/g;
  $genCode  =~ s/<ireadysAnd>/$str_ireadysAnd/g;
  $genCode  =~ s/<ivalids>/$str_ivalids/g;
  $genCode  =~ s/<ivalidsAnd>/$str_ivalidsAnd/g;
  $genCode  =~ s/<oreadys>/$str_oreadys/g;
  $genCode  =~ s/<oreadysAnd>/$str_oreadysAnd/g;
  $genCode  =~ s/<ireadyConns>/$str_ireadyConns/g;
  $genCode  =~ s/<ireadysOr>/$str_ireadysOr/g;
  $genCode  =~ s/<demux>/$str_demux/g;
  $genCode  =~ s/<mux>/$str_mux/g;
  $genCode  =~ s/<mux_def>/$str_mux_def/g;
  $genCode  =~ s/<ovalidsConcat>/$str_ovalidsConcat/g;
  $genCode  =~ s/<ovalidsConcat>/$str_ovalidsConcat/g;
  $genCode  =~ s/<instances>/$str_instances/g;
  $strPorts = "";
  $strInsts = "";
  $strConns = "";
  
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
  print "TyBEC: Generated module $modName\n";  
} 


# ============================================================================
# GENERATE TEST BENCH
# ============================================================================

sub genTestbench {
  # --------------------------------
  # >>> ARGS
  # --------------------------------
  my  ($fhGen             #file handler for output file
      ,$modName           #module_name
      ,$designName
      ,$outputRTLDir
      ,$ioVect
      ) = @_; 
      
  my $dfgroup = 'main'; 
  my %hash        = %{$main::CODE{main}};  #the hash from parsed code for this pipe function
  
  # --------------------------------
  # >>>>> Locals
  # --------------------------------
  my $timeStamp   = localtime(time);
  my $strBuf = ""; # temp string buffer used in code generation 

  # ---------------------------------------
  # >>>> Load template file, read contents
  # ---------------------------------------
  my $templateFileName = "$TyBECROOTDIR/hdlGenTemplates/template.testbench.v"; 
  open (my $fhTemplate, '<', $templateFileName)
    or die "Could not open file '$templateFileName' $!"; 

  my $genCode = read_file ($fhTemplate);
  close $fhTemplate;
 
  my $cwd = getcwd; #pwd needed for passing absolute path of results to xilinx ISE testbench

  # --------------------------------
  # >>>>> Update header and module name 
  # --------------------------------
  $genCode =~ s/<module_name>/$modName/g;
  $genCode =~ s/<design_name>/$designName/g;
  $genCode =~ s/<gen_ver>/$main::tybecRelease/g;
  $genCode =~ s/<timeStamp>/$timeStamp/g;
  $genCode =~ s/<globalVect>/$ioVect/g;
  
  # -------------------------------------------------------
  # >>>>> dataw, datat, streamw
  # -------------------------------------------------------
  my $datat; #complete type (e.g i32)
  my $dataw; #width in bits
  my $dataBase; #base type (ui, i, or float)
  #TODO: I am using the data type of the first stream I see in main (connectd to global memory object) to set data type in the top as well
  #but this is artificially limiting  $strBuf = $dataw;
  foreach (keys %{$main::CODE{main}{symbols}} ) {
    if ($main::CODE{main}{symbols}{$_}{cat} eq 'streamread') {
      $datat = $main::CODE{main}{symbols}{$_}{dtype};
      ($dataw = $datat)     =~ s/\D*//g;
      ($dataBase = $datat)  =~ s/\d*//g;
      #$dataw = $main::CODE{main}{symbols}{$_}{dtype};
      #$dataw =~ s/\D*//;
    }
  }
  $genCode =~ s/<dataw>/$dataw/g;
  

  
  #stream-width
  #same as dataw for ints, but for floats, we  need to add
  #2 extra control bits as they are needed by flopoco
  #my $streamw;
  #if($dataBase eq 'float')  {$streamw=$dataw+2;}
  #else                      {$streamw=$dataw;}
  
  #no need now, as flopoco control bits are added/removed internally for upwards host-code compatimilty
  my $streamw = $dataw;
  
  $genCode =~ s/<streamw>/$streamw/g;
  
  # -------------------------------------------------------
  # set latency
  # -------------------------------------------------------
  my $lat = $main::CODE{main}{performance}{lat};
  $genCode =~ s/<latency>/$lat/;

  # -------------------------------------------------------
  # size
  # -------------------------------------------------------
  my $size = $main::CODE{main}{bufsize};
  $genCode =~ s/<size>/$size/g;
  
  #output size may be different from input size
  my $sizeOutput = $main::CODE{main}{bufsizeOutput};
  $genCode =~ s/<sizeOutput>/$sizeOutput/g;

  # -------------------------------------------------------
  #buffers for creating code for different parts of the template
  # -------------------------------------------------------
  my $strPortWires  = "";
  my $strChildPorts = "";
  my $strDecGmemAr  = "";
  my $strInitArrays = "";
  my $strZeroPadAr  = "";
  my $strAssignInput= "";
  my $strAssignOuput= "";
  my $strFpHelper   ="";
  my $excFieldFlopoco='';
  my $bits2realOpen = '';
  my $bits2realClose= '';
  my $readCResults  = '';
  my $defFloat       = '';
  my $resultCType    = '';
  my $PT             = 'd';#default
  my $getScalarResGold   = '';
  my $getScalarResCalc   = '';
  my $getScalarResCalcEnd= '';
  my $result_t           = '';
  my $getScalarResGold2Compare= '';
  my $getScalarResCalc2Compare= '';
  my $strpackDataIn  = '';
  my $strpackDataOut = '';
  my $str_ivalid_toduts  = ''; 
  my $str_iready_fromduts= '';
  my $str_wire_iready_fromduts= '';
  
  my $array4verifyingResult = '';
  # -------------------------------------------------------
  # if float, include helper and also define macro, and type of resultC
  # also set how to print outputs using printfs (%d/%f)
  # -------------------------------------------------------
  if($dataBase eq 'float') {
    my $srcdir = "$TyBECROOTDIR/hdlGenTemplates";
    my $err;
    #I was earlier copying this helper file into HDL folder, but it is only used by 
    #testbench so best to keep it there
    #$err =copy("$srcdir/template.spFloatHelpers.v" , "$outputRTLDir/../hdl/spFloatHelpers.v"); 
    $err =copy("$srcdir/template.spFloatHelpers.v" , "$outputRTLDir/spFloatHelpers.v"); 
    $strFpHelper = "//helper functions for SP-floats\n"
#                 . "`include \"../hdl/spFloatHelpers.v\" "
                 . "`include \"spFloatHelpers.v\" "
                 ;
    $defFloat = '`define FLOAT';
    $PT       = 'f';
  }
  # -------------------------------------------------------
  # read ground truth from C simulation, set output print type
  # -------------------------------------------------------

  #I am moving folder structure in testcode to this format now (e.g. testcode 16), where versions are at top, and C and TIR are sub-folders
  #so this should be the default in most cases now
  $readCResults = "\$readmemh(\"../../../../../../c/verifyChex.dat\", resultfromC);\n";
  
  
  #this is the typical case (on laptop/modelsim)
  #$readCResults = "\$readmemh(\"../../../../../../../c/verifyChex.dat\", resultfromC);\n";
  
  #this is the case when each TIR has its local C version (e.g. unit testing in 2dshallow water)
  #$readCResults = "\$readmemh(\"../../../../../c/verifyChex.dat\", resultfromC);\n";
  
  

  #vivado likes absolute path (on bolama)
  #$readCResults =  "//Absolute path as readmemh behaviour unreliable across different simulators (vivado likes absolute path)\n";
  
    #if c has versions too
    #$readCResults .= "\$readmemh(\"$cwd/../../c/ver3/verifyChex.dat\", resultfromC);\n";
    
    #if c has single source folder
    #$readCResults .= "\$readmemh(\"$cwd/../c/verifyChex.dat\", resultfromC);\n";

  #in some test cases, each tir version has its own C version, this is manually set in the generated testbench
  #this is ugly FIXME
  #$readCResults = "\$readmemh(\"../../../../../../../c/verX/verifyChex.dat\", resultfromC);\n";
  
  
  if ($dataBase eq 'float') {
  $readCResults = "$readCResults\n"
                . ""
                ;
                
  }

  # -------------------------------------------------------
  # how many total inputs/outputs? 
  #   - create packed  busses
  #   - connect Xple ivalids, ireadys
  # -------------------------------------------------------
  my $ninputs = 0;
  my $noutputs = 0;
  foreach my $key (keys %{$main::CODE{main}{allocaports}}) {
    my $dir =$main::CODE{main}{allocaports}{$key}{dir};
    $ninputs  = $ninputs+1  if($dir eq 'input');
    $noutputs = $noutputs+1 if($dir eq 'output');
    
    #in case of multiple outputs, pick the last one for result verification
    #since $key is name of the stream, I have to lookup the hash to find the corresponding memory array
    #this should be deterministic FIXME
    $array4verifyingResult = $main::CODE{main}{symbols}{"%$key"}{produces}[0] if($dir eq 'output');
    $array4verifyingResult =~ s/\%//;
  }
  #hardwired for 2dshallowwater
  #$array4verifyingResult = 'n_u_j_k';
  
  #SDX limits  AXI port widths to 2^N
  #my log2 is already defined with CEIL to round up 
  my $ninputs_t  = 2**log2($ninputs); #total inputs with padding
  my $ninputs_p  = $ninputs_t - $ninputs; #extra inputs padded
  my $noutputs_t = 2**log2($noutputs); #total outputs with padding
  my $noutputs_p = $noutputs_t - $noutputs; #extra inputs padded
  
  #handle ivalid, iready, for each input
  my $loopto = $noutputs;
  $loopto = 1 if ($main::ocxTempVer eq 't08'); #for template version 9, inputs are coalesced (FIXME)
  
  #this is now redundant as I am coalescing the IOs
  foreach my $i (0..$loopto-1) {
    my $c = ($i == 0) ? "" : ", ";
    $str_ivalid_toduts        .= "$c"."ivalid_todut"; 
    $str_iready_fromduts      .= "$c"."iready_fromdut$i";
    $str_wire_iready_fromduts .= "wire iready_fromdut$i;\n";
  }

  # -------------------------------------------------------
  # generate ports and connection in instantiation of DUT
  # -------------------------------------------------------
  foreach my $key (keys %{$main::CODE{main}{allocaports}}){
    #name of streamign port
    my $name=$key;
    my $nameInHash="%".$name;
    my $nameWire = $name."_data";
    
    #name of relevant memory object (global memory array)
    my $nameOfMem;   
    my $dir =$main::CODE{main}{allocaports}{$name}{dir};
    
    #get name of mem
    if($dir eq 'input') {$nameOfMem=$main::CODE{main}{symbols}{$nameInHash}{consumes}[0];}
    else                {$nameOfMem=$main::CODE{main}{symbols}{$nameInHash}{produces}[0];}
    $nameOfMem=~s/\%//;

    
    #create connection wires
    #if($ioVect==1){
    #  $strPortWires = $strPortWires ."wire [`STREAMW-1:0] $name"."_data;\n";
    #  $strChildPorts= $strChildPorts.", .$name"."  ($name"."_data)\n";
    #}
    #else {
      #if($dir eq 'input'){
        for (my $v=0; $v<$ioVect; $v++) {
          $strPortWires = $strPortWires ."wire signed [`STREAMW-1:0] $name"."_data_s$v;\n";
          $strChildPorts= $strChildPorts.", .$name"."_s$v"."  ($name"."_data_s$v)\n";
        }
      

      #packing data wires in/out of DUT
      #the scalars in vectors are organized big-endian order (higher elements of vector are towards MSB)
      #so we have to count down when concatenating
      for (my $v=$ioVect-1; $v>=0; $v--) {
        if($dir eq 'input'){
          $strpackDataIn  = $strpackDataIn
                          . "  ,$name"."_data_s$v\n"
                          ;
          }
        else {
         $strpackDataOut  = $strpackDataOut
                          . ",$name"."_data_s$v "
                          ;
        }
      }#for
      

      
      #}
      #else {
      #  for (my $v=0; $v<$ioVect; $v++) {
      #    $strPortWires = $strPortWires ."wire [`STREAMW-1:0] $name"."_data_s$v;\n";
      #    $strChildPorts= $strChildPorts.", .$name"."_s$v ($name"."_data_s$v)\n";
      #  }
      #}
    #}
    
    #declare and initialize global memory arrays
    $strDecGmemAr = $strDecGmemAr ."reg signed [`DATAW-1:0]  $nameOfMem  [0:`SIZE-1];\n";
    #print "nameInHash = $nameInHash\n";
    
    #if floats, then prepend with floating bias
    if($dir eq 'input'){
      if($dataBase eq 'float'){
        $strInitArrays= $strInitArrays
                      ."    $nameOfMem\[index0\] = realtobitsSingle(3.14+index0+1);\n";}
      else {
        #ONLY For 2dshallow - FIXME
        if ($nameOfMem eq 'wet_j_k') {
          $strInitArrays.= "    $nameOfMem\[index0\] = 1;\n";}
        else {
          $strInitArrays.= "    $nameOfMem\[index0\] = index0+1;\n";}
      }
    }
    else{
      $strInitArrays= $strInitArrays."    $nameOfMem\[index0\] = 0;\n";
      #for debug message
      $genCode  =~ s/<outputData>/$nameOfMem/g;
      }
      
    $strZeroPadAr = $strZeroPadAr ."$nameOfMem\[index1\] = 0;\n";
    
    #connect data wires to global memories
    my $flPre= '';#extra pre/post characters when floatin data
    my $flPst= '';#extra pre/post characters when floatin data
    #if($ioVect==1){
    #  if($dataBase eq 'float') {
    #  $excFieldFlopoco = 
    #     "//Exception fields for flopoco                                         \n"
    #    ."//A 2-bit exception field                                              \n"
    #    ."//00 for zero, 01 for normal numbers, 10 for infinities, and 11 for NaN\n"
    #    ."wire [1:0] fpcEF = 2'b01;                                              \n";
    #    $flPre = '{fpcEF,';
    #    $flPst = '}';
    #  }
    #  
    #  $strAssignInput = $strAssignInput ."assign $name"."_data = $flPre $nameOfMem\[lincount\] $flPst;\n"
    #    if($dir eq 'input');
    #  $strAssignOuput = $strAssignOuput  ."    $nameOfMem\[effaddr\] <= $nameWire"."_s$v;\n";
    #    if($dir eq 'output');
    #}
    #else {
      for (my $v=0; $v<$ioVect; $v++) {
        
        #the following is redundant now, as flopoco control bits are handled internally
        #if($dataBase eq 'float') {
        #  $excFieldFlopoco = 
        #   "//Exception fields for flopoco                                         \n"
        #  ."//A 2-bit exception field                                              \n"
        #  ."//00 for zero, 01 for normal numbers, 10 for infinities, and 11 for NaN\n"
        #  ."wire [1:0] fpcEF = 2'b01;                                              \n";
        #  $flPre = '{fpcEF,';
        #  $flPst = '}';
        #}

        if($dir eq 'input'){ 
          $strAssignInput = $strAssignInput ."assign $name"."_data_s$v = $flPre $nameOfMem\[lincount+$v\] $flPst;\n"
        } else {
          my $sPos = $v*$dataw;
          my $ePos = ($v+1)*$dataw-1;
          #calculating starting and endign indices of relevant scalar from
          #concatenated vector output
            ##redundant as output is now already scalarized (unpacked)
          $strAssignOuput = $strAssignOuput  
                          ."    $nameOfMem\[effaddr+$v\] <= $nameWire"."_s$v;\n";
          #$strAssignOuput = $strAssignOuput  ."    $nameOfMem\[effaddr\] <= $nameWire"."_s$v;\n";
        }#else
        #if($dir eq 'input') {
        #  $strAssignInput = $strAssignInput ."assign $name"."_data_s$v = $nameOfMem\[lincount+$v\];\n";
        #}
        #else {
        #  #$strAssignOuput = $strAssignOuput  ."    $nameOfMem\[effaddr+$v\] <= $nameWire"."_v$v;\n"
        #
        #                  #."    $nameOfMem\[effaddr+$v\] <= $nameWire"."[$ePos:$sPos];\n";
        #}
      }#for
    #}
    
    #checking and displaying results
    if ($dataBase eq 'float') {
      $bits2realOpen      = 'bitstorealSingle(';
      $bits2realClose     = ')';
      $getScalarResGold   = "bitstorealSingle(resultfromC[index]);";
      $getScalarResCalc   = "bitstorealSingle(";
      $getScalarResCalcEnd= "[index]);";
      $result_t           = 'real';
      $getScalarResGold2Compare = "\$rtoi(`VERPREC*scalarResGold);";
      $getScalarResCalc2Compare = "\$rtoi(`VERPREC*scalarResCalc);";
    }
    else {
      $getScalarResGold   = "resultfromC[index];";
      $getScalarResCalc   = "";
      $getScalarResCalcEnd= '[index];';
      $result_t           = 'integer';
      $getScalarResGold2Compare = "scalarResGold;";
      $getScalarResCalc2Compare = "scalarResCalc;";
    }
    
  }#foreach my $key (keys %{$main::CODE{main}{allocaports}}){
  
  #padding if needed
  foreach my $p(0..$ninputs_p-1) {
    #padding has to start at the top (MSByte)
    $strpackDataIn = "  ,32'b0\n".$strpackDataIn;
  }

  
  #remove first "," from generated strings where needed
  $strpackDataIn  =~ s/,{1}/ /;
  $strpackDataOut =~ s/,{1}/ /;
  
  #insert created strings into appropriate tag locations
  $genCode  =~ s/<defFloat>/$defFloat/g;
  $genCode  =~ s/<PT>/$PT/g;
  $genCode  =~ s/<portwires>/$strPortWires/g;
  $genCode  =~ s/<connectchildports>/$strChildPorts/g;
  $genCode  =~ s/<declaregmemarrays>/$strDecGmemAr/g;
  $genCode  =~ s/<initarrays>/$strInitArrays/g;
  $genCode  =~ s/<zeropadarrays>/$strZeroPadAr/g;
  $genCode  =~ s/<assigninputdata>/$strAssignInput/g;
  $genCode  =~ s/<assignoutputdata>/$strAssignOuput/g;
  $genCode  =~ s/<ioVect>/$ioVect/g;
  $genCode  =~ s/<FpHelper>/$strFpHelper/g;
  $genCode  =~ s/<streamw>/$streamw/g;
  $genCode  =~ s/<excFieldFlopoco>/$excFieldFlopoco/g;
  $genCode  =~ s/<bits2realOpen>/$bits2realOpen/g;
  $genCode  =~ s/<bits2realClose>/$bits2realClose/g;
  $genCode  =~ s/<readCResults>/$readCResults/;
  $genCode  =~ s/<getScalarResGold>/$getScalarResGold/;
  $genCode  =~ s/<getScalarResCalc>/$getScalarResCalc/;
  $genCode  =~ s/<getScalarResCalcEnd>/$getScalarResCalcEnd/;
  $genCode  =~ s/<result_t>/$result_t/g;
  $genCode  =~ s/<getScalarResGold2Compare>/$getScalarResGold2Compare/g;
  $genCode  =~ s/<getScalarResCalc2Compare>/$getScalarResCalc2Compare/g;
  $genCode  =~ s/<packDataIn>/$strpackDataIn/g;
  $genCode  =~ s/<packDataOut>/$strpackDataOut/g;
  $genCode  =~ s/<ninputs>/$ninputs+$ninputs_p/g;
  $genCode  =~ s/<noutputs>/$noutputs+$noutputs_p/g;
  $genCode  =~ s/<ivalid_toduts>/$str_ivalid_toduts/g;
  $genCode  =~ s/<iready_fromduts>/$str_iready_fromduts/g;
  $genCode  =~ s/<wire_iready_fromduts>/$str_wire_iready_fromduts/g;
  
  $genCode  =~ s/<array4verifyingResult>/$array4verifyingResult/g;
  
  # --------------------------------
  # >>>>> Write to file
  # --------------------------------
  $genCode =~ s/\r//g; #to remove the ^M  
  print $fhGen $genCode;
  
  print "TyBEC: Generated module $modName\n";  
  
}  

