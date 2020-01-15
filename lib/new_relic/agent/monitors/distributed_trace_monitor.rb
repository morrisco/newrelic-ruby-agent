# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/rpm/blob/master/LICENSE for complete details.

module NewRelic
  module Agent
    module DistributedTracing
      class DistributedTraceMonitor < InboundRequestMonitor
        def on_finished_configuring(events)
          return unless NewRelic::Agent.config[:'distributed_tracing.enabled']
          events.subscribe(:before_call, &method(:on_before_call))
        end

        NEWRELIC_TRACE_KEY = 'HTTP_NEWRELIC'

        def on_before_call(request)
          return unless NewRelic::Agent.config[:'distributed_tracing.enabled']
          return unless payload = request[NEWRELIC_TRACE_KEY]
          return unless txn = Tracer.current_transaction

          if txn.distributed_tracer.accept_distributed_trace_payload payload
            txn.distributed_tracer.distributed_trace_payload.caller_transport_type = DistributedTraceTransportType.for_rack_request(request)
          end
        end
      end
    end
  end
end