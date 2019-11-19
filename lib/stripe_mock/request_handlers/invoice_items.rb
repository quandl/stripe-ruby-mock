module StripeMock
  module RequestHandlers
    module InvoiceItems

      def InvoiceItems.included(klass)
        klass.add_handler 'post /v1/invoiceitems',        :new_invoice_item
        klass.add_handler 'post /v1/invoiceitems/(.*)',   :update_invoice_item
        klass.add_handler 'get /v1/invoiceitems/(.*)',    :get_invoice_item
        klass.add_handler 'get /v1/invoiceitems',         :list_invoice_items
        klass.add_handler 'delete /v1/invoiceitems/(.*)', :delete_invoice_item
      end

      def new_invoice_item(route, method_url, params, headers)
        params[:id] ||= new_id('ii')
        invoice_items[params[:id]] = Data.mock_invoice_item(params)
      end

      def update_invoice_item(route, method_url, params, headers)
        route =~ method_url
        list_item = assert_existence :list_item, $1, invoice_items[$1]
        list_item.merge!(params)
      end

      def delete_invoice_item(route, method_url, params, headers)
        route =~ method_url
        assert_existence :list_item, $1, invoice_items[$1]

        invoice_items[$1] = {
          id: invoice_items[$1][:id],
          deleted: true
        }
      end

      def list_invoice_items(route, method_url, params, headers)
        items = filter_line_items(invoice_items.values, params)
        Data.mock_list_object(items, params)
      end

      def get_invoice_item(route, method_url, params, headers)
        route =~ method_url
        assert_existence :invoice_item, $1, invoice_items[$1]
      end

      def filter_line_items(line_items, filters)
        line_items.select do |item|
          if item[:customer] == filters[:customer]
            pending_filter(item, filters[:pending]) if filters.key?(:pending)
          end
        end
      end

      def pending_filter(item, pending)
        if pending
          item if item[:invoice].nil?
        else
          item unless item[:invoice].nil?
        end
      end
    end
  end
end
