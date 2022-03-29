class ExportJob < ApplicationJob
  queue_as :export

  def perform(*args)
    universe_ids = args.shift
    format       = args.shift

    # design: left side 1/2 - list universes with toggle/checkboxes to include
    #         right side 1/2 - radios for format, checkboxes for options after
    #          (include hidden? include IDs? include blank fields?)


  end
end
