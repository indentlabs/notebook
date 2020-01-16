class PaypalService < Service
  include PayPalCheckoutSdk::Orders

  def self.create_prepay_invoice(n_months)
    # Create a Paypal invoice to redirect to for payment
    request = PayPalCheckoutSdk::Orders::OrdersCreateRequest::new
    request.request_body({
      intent: "CAPTURE",
      purchase_units: [{
        amount: {
          currency_code:       "USD",
          value:               PaypalService.months_price(n_months),
          description:         "Notebook.ai Premium (#{n_months} month#{'s' unless n_months == 1})",
          # payment_instruction: "placeholder text",
          soft_descriptor:     "Notebook.ai Premium"
        }
      }]
    })

    begin
      response = PaypalService.client.execute(request)
      order    = response.result
      order

    rescue PayPalHttp::HttpError => ioe
      # Something went wrong server-side
      # puts ioe.status_code
      # puts ioe.headers["debug_id"]
      raise ioe.inspect
    end
  end

  def self.capture_invoice_funds(invoice_id)
    request = PayPalCheckoutSdk::Orders::OrdersCaptureRequest::new(invoice_id)

    begin
      # Call API with your client and get a response for your call
      response = client.execute(request) 
      
      # If call returns body in response, you can get the deserialized version from the result attribute of the response
      # order = response.result
      # puts order

    rescue PayPalHttp::HttpError => ioe
      # Something went wrong server-side
      # puts ioe.status_code
      # puts ioe.headers["debug_id"]
      raise ioe.inspect
    end
  end
  
  # Remove after a successful release
  # def self.checkout_url(invoice, return_path)
  #   app_host    = Rails.env.production? ? 'https://www.notebook.ai' : 'http://localhost:3000'
  #   paypal_host = Rails.env.production? ? 'https://www.paypal.com' : 'https://www.sandbox.paypal.com'

  #   values = {
  #     business: 'sb-43r7at861878@business.example.com',
  #     cmd: "_xclick",
  #     # image_url: 150x50 url

  #     upload: 1,

  #     invoice:      invoice.paypal_id,
  #     item_name:   "Notebook.ai Premium",
  #     item_number: "#{invoice.months} month#{'s' unless invoice.months == 1} of Premium",
  #     quantity:    '1',
  #     amount:      months_price(invoice.months),

  #     no_note: 1,
  #     no_shipping: 1,

  #     return: "#{app_host}#{return_path}",
  #     cancel_return: "#{app_host}/my/billing/prepay",
  #   }

  #   "#{paypal_host}/cgi-bin/webscr?" + values.to_query
  # end

  # Remove after a successful release
  # def self.capture_payment(paypal_invoice_id)
  #   resp = Faraday.post("https://api.sandbox.paypal.com/v2/checkout/orders/#{paypal_invoice_id}/capture") do |req|
  #     # req.params['limit'] = 100
  #     req.headers['Content-Type']  = 'application/json'
  #     req.headers['Authorization'] = 'Basic <tokens>'
  #     # req.body = {query: 'salmon'}.to_json
  #   end
  # end

  def self.order_info(order_id)
    request = OrdersGetRequest::new(order_id)
    response = client::execute(request)

    # puts "Status Code: " + response.status_code.to_s
    # puts "Status: " + response.result.status
    # puts "Order ID: " + response.result.id
    # puts "Intent: " + response.result.intent
    # puts "Links:"
    # for link in response.result.links
    #   puts "\t#{link["rel"]}: #{link["href"]}\tCall Type: #{link["method"]}"
    # end
    # puts "Gross Amount: " + response.result.purchase_units[0].amount.currency_code + response.result.purchase_units[0].amount.value

    {
      order_id:    response.result.id,
      status:      response.result.status,
      status_code: response.status_code.to_s,
      intent:      response.result.intent
    }
  end

  def self.months_price(n_months)
    case n_months
    when 1
      9.00
    when 3
      24.00
    when 6
      48.00
    when 12
      84.00
    else
      raise "Invalid month prepay: #{n_months}"
    end
  end

  def self.client
    @paypal_client ||= begin
      client_id     = Rails.application.config.paypal[:client_id]
      client_secret = Rails.application.config.paypal[:client_secret]
  
      environment = if Rails.env.production? 
        PayPal::PayPalEnvironment.new(client_id, client_secret)
      else
        PayPal::SandboxEnvironment.new(client_id, client_secret)
      end

      PayPal::PayPalHttpClient.new(environment)
    end
  end

end