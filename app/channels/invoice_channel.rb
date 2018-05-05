class InvoiceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "invoices"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
