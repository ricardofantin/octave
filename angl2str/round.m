function [num] = round (X, N = 0, type = "decimals")
  if (strcmp (type, "decimals") == 0 && strcmp (type, "significant") == 0)
    error (["round.m: Error, type should be \"decimals\" or \"significant\". Received " type " ."]);
    print_usage ();
  elseif (isnumeric (N) == 0)
    str = num2str (N);
    error (["round.m: Error, second argument N should be an integer. Received " str " ."]);
    print_usage ();
  endif
  
  if (N == 0 && strcmp (type, "decimals"))
    num = floor (X + 0.5);
    return;
  endif
  
  if (strcmp (type, "decimals"))
    multiplier = 10 .** (N);
    num = (floor ((X .* multiplier) + 0.5)) ./ multiplier;
  else # type is significant
    # first need to discover the number of digits before point
    sig = floor (log10 (X));
    multiplier = 10 .** (sig + 1 - N);
    num = (floor ((X ./ multiplier) + 0.5)) .* multiplier;
  endif
endfunction