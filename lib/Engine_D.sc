Engine_D : CroneEngine {
  var srate=48000, sdepth=32;
  var crossover=1400,
      distAmount=15, 
      lowbias=0.04, 
      highbias=0.12, 
      hissAmount=0.5, 
      cutoff=11500,
      gateThreshold=0.01;

  var <saturator;
  
  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    ~tf =  Env([-0.7, 0, 0.7], [1,1], [8,-8]).asSignal(1025);
    ~tf = ~tf + (
          Signal.sineFill(
            1025,
            (0!3) ++ [0,0,1,1,0,1].scramble,
            {rrand(0,2pi)}!9
        )/10;
      );
    ~tf = ~tf.normalize;
    ~tfBuf = Buffer.loadCollection(context.server, ~tf.asWavetableNoWrap);

    SynthDef(\Saturator, { |inL, inR, out, srate=48000, sdepth=32, crossover=1400, distAmount=15, lowbias=0.04, highbias=0.12, hissAmount=0.5, cutoff=11500, foldLow=0.0, foldHigh=1.0, gateThreshold=0.01|
      var dryIn = SoundIn.ar([0,1]);
      var input = Decimator.ar(dryIn, srate, sdepth);
      var crossAmount = 50;

      var lpf = DFM1.ar(
        input, 
        crossover + crossAmount,
        0,
        1,
        0
      ) * lowbias;

      var hpf = DFM1.ar(
        input,
        crossover - crossAmount,
        0,
        1,
        1
      ) * highbias;

      var beforeHiss = Mix.new([
        Mix.new([lpf,hpf]),
        HPF.ar(Mix.new([PinkNoise.ar(0.001), Dust.ar(5,0.002)]), 2000, hissAmount)
      ]);

      var compressed = Compander.ar(beforeHiss, input,
          thresh: 0.2,
          slopeBelow: 1,
          slopeAbove: 0.3,
          clampTime:  0.001,
          relaxTime:  0.1, 
      );
      var shaped = Shaper.ar(~tfBuf, compressed  * distAmount);

      var afterHiss = HPF.ar(Mix.new([PinkNoise.ar(1), Dust.ar(5,1)]), 2000, 1);

      var duckedHiss = Compander.ar(afterHiss, input,
          thresh: 0.4,
          slopeBelow: 1,
          slopeAbove: 0.2,
          clampTime: 0.01,
          relaxTime: 0.1, 
      ) * 0.5 * hissAmount;

      var morehiss = Mix.new([
        duckedHiss, 
        Mix.new([lpf * (1 / lowbias) * (distAmount/10), shaped])
      ]);

      var limited = Limiter.ar(Mix.new([
        input * 0.5,
        morehiss
      ]), 0.9, 0.01);

      var gated = Compander.ar(limited, dryIn,
          thresh: gateThreshold,
          slopeBelow: 20,
          slopeAbove: 1,
          clampTime: 0.01,
          relaxTime: 0.1
      );

      Out.ar(out, DFM1.ar(
        gated,
        Lag.kr(cutoff, 0.1),
        0,
        1,
        0
      ));
    }).add;

    context.server.sync;

    saturator = Synth.new(\Saturator, [
      \inL, context.in_b[0].index,      
      \inR, context.in_b[1].index,
      \out, context.out_b.index,
      \srate, 48000,
      \sdepth, 32,
      \crossover, 1400,
      \distAmount, 15,
      \lowbias, 0.04,
      \highbias, 0.12,
      \hissAmount, 0.2,
      \cutoff, 11500,
      \gateThreshold, 0.01], 
    context.xg);

    this.addCommand("srate", "i", {|msg|
      saturator.set(\srate, msg[1]);
    });
    
    this.addCommand("sdepth", "f", {|msg|
      saturator.set(\sdepth, msg[1]);
    }); 

    this.addCommand("crossover", "i", {|msg|
      saturator.set(\crossover, msg[1]);
    });
    
    this.addCommand("distAmount", "i", {|msg|
      saturator.set(\distAmount, msg[1]);
    }); 

    this.addCommand("lowbias", "f", {|msg|
      saturator.set(\lowbias, msg[1]);
    }); 

    this.addCommand("highbias", "f", {|msg|
      saturator.set(\highbias, msg[1]);
    }); 

    this.addCommand("hissAmount", "f", {|msg|
       var amp = msg[1]*0.1;
       if(amp>0.001, {amp = amp.linexp(0.001, 1, 0.001, 0.25)});
       saturator.set(\hissAmount, amp);
    });

    this.addCommand("gateThreshold", "f", {|msg|
      saturator.set(\gateThreshold, msg[1]);
    });
    
  }

  free {
    saturator.free;
  }
}
