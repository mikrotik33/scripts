###########################
# Left trim space function
:global gfStrLTrim do={
  :local n -1;
  :do {
    :set n ($n+1);
  } while=(([:pick $1 $n]=" ") && ($n<[:len $1]));
  :return [:pick $1 $n [:len $1]];
}
###########################
# Right trim space function
:global gfStrRTrim do={
  :local n [:len $1];
  :do {
    :set n ($n-1);
  } while=(([:pick $1 $n]=" ") && ($n>=0));
  :return [:pick $1 0 ($n+1)];
}
###########################
# Trim space function
:global gfStrTrim do={
  :local n -1;
  :do {
    :set n ($n+1);
  } while=(([:pick $1 $n]=" ") && ($n<[:len $1]));
  :local res [:pick $1 $n [:len $1]];
  :set n [:len $res];
  :do {
    :set n ($n-1);
  } while=(([:pick $res $n]=" ") && ($n>=0));
  :return [:pick $res 0 ($n+1)];
}
###########################
:global gfStrLeft do={
  :local pos [:find $1 $2 -1];
  :if ($pos >= 0) do={
    :return [:pick $1 0 $pos];
  }
  :return $1;
}
###########################
:global gfStrRight do={
  :local pos [:find $1 $2 -1];
  :if ($pos >= 0) do={
    :return [:pick $1 ($pos+[:len $2]) [:len $1]];
  }
  :return "";
}
###########################
# 1$ xxx#Key__{Value123}xxx
# $2 = "#Key",
# $3 = "{"
# $4 = "}"
# Return = "Value123"
#

:global gfGetKeyBlock do={
  :local res "";
  :local pos [:find $1 $2 -1];
  :if ($pos >= 0) do={
    :set pos ($pos + [:len $2])
    :set pos [:find $1 $3 ($pos-1)];
    :if ($pos >= 0) do={
      :set pos ($pos + [:len $3])
      :local end [:find $1 $4 ($pos-1)];
      :if (!($end >= 0)) do={ :set end [:len $1];  }
      :set res [:pick $1 $pos $end];
    }
  }
  :return $res;
}
###########################
# $1 - input string
# defaults - acc array with default values (defaults=({}))
# quotes - quote symbols (quotes="\"")
# equals - equal symbols (equals="=")
# spaces - space symbols (spaces=" \t\n\r")
#
# Return array of pairs key=value parsed from input string
#

:global gfParseToDic do={
  :local res;
  :if ([:len $defaults]=0) do={
    :set res ({[]});
  } else={
    :set res $defaults;
  }
  :local bLex false; :local sLex "";
  :local bKey true;  :local sKey "";
  :local bVal false; :local sVal "";
  :local bQuo false;

  :local bSpace;
  :local sSpace $spaces;
  :if ([:len $sSpace] = 0) do={
    :set $sSpace " \t\n\r";
  }

  :local bEqual;
  :local sEqual $equals;
  :if ([:len $sEqual] = 0) do={
    :set $sEqual "=";
  }

  :local bQuote;
  :local sQuote $quotes;
  :if ([:len $sQuote] = 0) do={
    :set $sQuote "\"";
  }
  :local sQuoNow;

  :local c; 
  :local i 0;
  :while ($i < [:len $1]) do={
    :set c [:pick $1 $i];
    :set bEqual ([:find $sEqual $c -1] >= 0);
    :set bSpace ([:find $sSpace $c -1] >= 0);
    :if ($bQuo) do={
      :set bQuote ($c=$sQuoNow);
    } else={
      :set bQuote ([:find $sQuote $c -1] >= 0);
      :set sQuoNow $c;
    }
    :if (($bQuo && $bLex && $bQuote || (!$bQuo && (($bLex && $bSpace) || ($bEqual && !$bVal))))) do={
      :if ($bVal) do={
        :set ($res->$sKey) $sLex;
        :set bVal false;
        :set bKey true;
      } else={
        :if ($bEqual) do={
          :set bVal true;
        }
        :if ($bKey) do={
          :set bKey false;
          :set sKey $sLex;
        }
      }
      :set bQuo false;
      :set bLex false;
      :set sLex "";
    } else={
      :if ($bLex) do={
        :if (!$bSpace || ($bSpace && $bQuo)) do={
          :set sLex ($sLex . $c);
        }
      } else={
        :if ($bQuote) do={
          :if (!$bKey && !$bVal) do={
            :set ($res->$sKey) "";
            :set bKey true;
          }
          :set bLex true;
          :set bQuo true;
        } else={
          :if (!$bSpace) do={
            :if (!$bKey && !$bVal) do={
              :set ($res->$sKey) "";
              :set bKey true;
            }
            :set bLex true;
            :set sLex $c;
          }
        }
      }
    }
    :set i ($i+1);
  }
  :if ($bVal) do={
    :set ($res->$sKey) $sLex;
  } else={
    :if ($bKey) do={
      :if ([:len $sLex] > 0) do={ :set ($res->$sLex) ""; }
    } else={
      :if ([:len $sKey] > 0) do={ :set ($res->$sKey) ""; }
    }
  }
  :return $res;
}
