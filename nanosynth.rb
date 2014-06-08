### Nanosynth
### Copyright (C) 2014 Joel Strait
###
### This is a very simple sound generator capable of creating sound based on
### five types of wave: sine, square, sawtooth, triangle, and noise.
###
### This is intended as a learning tool, to show a ground-floor example
### of how to create sound using Ruby. Clarity has been favored over
### performance, error-handling, succinctness, etc.
###
### Example usage:
###   ruby nanosynth.rb sine 440.0 0.5
###
### The above usage will create a Wave file called "mysound.wav" in the current
### working directory. You can play this file using pretty much any media player.
###
### This program requires the WaveFile gem:
###
###   gem install wavefile
###
### If you're on a Mac, you can generate the sound and play it at the same time
### by using the afplay command:
###
###   ruby nanosynth.rb sine 440.0 0.5 && afplay mysound.wav

gem 'wavefile', '=0.6.0'
require 'wavefile'

OUTPUT_FILENAME = "mysound.wav"
SAMPLE_RATE = 44100
TWO_PI = 2 * Math::PI
RANDOM_GENERATOR = Random.new

def main
  # Read the command-line arguments.
  wave_type = ARGV[0].to_sym    # Should be "sine", "square", "saw", "triangle", or "noise" 
  frequency = ARGV[1].to_f      # Should be between 20.0 and 20000.0 to be audible.
                                # 440.0 is the same as middle-A on a piano.
  max_amplitude = ARGV[2].to_f  # Should be between 0.0 (silence) and 1.0 (full volume).
                                # Amplitudes above 1.0 will result in distortion (or other weirdness).

  # Generate 1 second of sample data at the given frequency and amplitude.
  # Since we are using a sample rate of 44,100Hz, 44,100 samples are required for one second of sound.
  samples = generate_sample_data(wave_type, 44100, frequency, max_amplitude)

  # Save the sound to a 16-bit, monophonic Wave file using the WaveFile gem.
  # Use a sample rate of 44,100Hz.
  buffer = WaveFile::Buffer.new(samples, WaveFile::Format.new(:mono, :float, 44100))
  WaveFile::Writer.new(OUTPUT_FILENAME, WaveFile::Format.new(:mono, 16, 44100)) do |writer|
    writer.write(buffer)
  end
end

def generate_sample_data(wave_type, num_samples, frequency, max_amplitude)
  position_in_period = 0.0
  position_in_period_delta = frequency / SAMPLE_RATE

  # Initialize an array of samples set to 0.0. Each sample will be replaced with
  # an actual value below.
  samples = [].fill(0.0, 0, num_samples)

  num_samples.times do |i|
    # Add next sample to sample list. The sample value is determined by
    # plugging the period offset into the appropriate wave function.

    if wave_type == :sine
      samples[i] = Math::sin(position_in_period * TWO_PI) * max_amplitude
    elsif wave_type == :square
      samples[i] = (position_in_period >= 0.5) ? max_amplitude : -max_amplitude
    elsif wave_type == :saw
      samples[i] = ((position_in_period * 2.0) - 1.0) * max_amplitude
    elsif wave_type == :triangle
      if(position_in_period < 0.5)
        sample = ((position_in_period * 4.0) - 1.0) * max_amplitude
      else
        sample = (1.0 - ((position_in_period - 0.5) * 4.0)) * max_amplitude
      end

      samples[i] = sample
    elsif wave_type == :noise
      samples[i] = RANDOM_GENERATOR.rand(-max_amplitude..max_amplitude)
    end

    position_in_period += position_in_period_delta
    
    # Constrain the period between 0.0 and 1.0
    if(position_in_period >= 1.0)
      position_in_period -= 1.0
    end
  end
  
  samples
end

main