
require "./da_process/*"

class DA_Process

  module Class_Methods
    private def capture_output_and_error(cmd : String)
      args = cmd.split
      io = IO::Memory.new
      stat = Process.run(args.shift, args, output: io, error: io)
      io.rewind
      { io.to_s, stat }
    end

    def output(cmd : String)
      capture_output_and_error(cmd).first
    end

    def output!(cmd : String)
      pair = capture_output_and_error(cmd)
      stat = pair.last
      success! stat
      pair.first
    end

    def success?(stat)
      is_fail = !stat.success? || !stat.normal_exit? || stat.signal_exit?
      !is_fail
    end

    def success!(cmd : String, output = STDOUT, error = STDERR, input = Process::Redirect::Close)
      args = cmd.split
      success! Process.run(args.shift, args, output: output, error: error, input: input)
    end

    def success!(stat : Process::Status)
      return stat if success?(stat)
      STDERR.puts "Exit signal: #{stat.exit_signal}" if stat.signal_exit?
      Process.exit stat.exit_code
    end
  end # === module Base

  extend Class_Methods

  # =============================================================================
  # Instance
  # =============================================================================

  getter output
  getter error
  getter input
  getter cmd_name : String
  getter args : Array(String)
  getter stat : Process::Status

  def initialize(
    @cmd : String,
    @input = Process::Redirect::Close
  )
    @output = o = IO::Memory.new
    @error  = e = IO::Memory.new
    @args = cmd.split
    @cmd_name = args.shift
    @stat = Process.run(cmd_name, args, output: o, error: e, input: @input)
    o.rewind
    e.rewind
  end # === def initialize

  def success?
    self.class.success?(@stat)
  end

  def error?
    !success?
  end

end # === module DA_Process
