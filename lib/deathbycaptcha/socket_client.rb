require 'json'
require 'digest/md5'
require 'thread'
require 'socket'
require 'base64'

module DeathByCaptcha
  
  #
  # DeathByCaptcha Socket API client
  #
  class SocketClient < DeathByCaptcha::Client
    
    #
    # Socket API server's host & ports range.
    #
    @@socket_host = 'api.deathbycaptcha.com'
    @@socket_ports = (8123...8131).to_a
    
    def initialize(username, password, extra = {})
      @mutex = Mutex.new
      @socket = nil
      
      super(username, password, extra)
    end
    
    def get_user
      call('user', userpwd)
    end
    
    def get_captcha(cid)
      call('captcha', {:captcha => cid})
    end

    def report(cid)
      call("captcha/#{cid}/report", userpwd)[:is_correct]
      
      data = userpwd
      data['captcha'] = cid
      not call('report', data)[:is_correct]
    end
    
    def remove(cid)
      not call("captcha/#{cid}/remove", userpwd)[:captcha]
      
      data = userpwd
      data['captcha'] = cid
      not call('remove', data)[:captcha]
    end
    
    #
    # Protected methods.
    #
    protected
    
    def upload(captcha, is_case_sensitive=false, is_raw_content=false)
      data = userpwd
      data[:captcha] = Base64.encode64(load_file(captcha, is_raw_content).read)
      
      data[:is_case_sensitive] = is_case_sensitive ? 1 : 0
      response = call('upload', data)
      
      response
    end
    
    #
    # Private methods.
    #
    private
    
    def connect
      unless @socket
        log('CONN')
        
        begin
          random_port = @@socket_ports[rand(@@socket_ports.size)]
          
          # Creates a new Socket.
          addr = Socket.pack_sockaddr_in(random_port, @@socket_host)
          
          @socket = Socket.new(:INET, :STREAM)
          @socket.connect_nonblock(addr)
        rescue Exception => e
          if e.errno == 36 # EINPROGRESS
            # Nothing.
          else
            close # Closes the socket.
            log('CONN', 'Could not connect.')
            log('CONN', e.backtrace.join('\n'))
            
            raise e
          end
        end
        
      end
      
      @socket
    end
    
    def close
      if @socket
        log('CLOSE')
        
        begin
          @socket.close
        rescue Exception => e
          log('CLOSE', 'Could not close socket.')
          log('CLOSE', e.backtrace.join('\n'))
        ensure
          @socket = nil
        end
      end
    end
    
    def send(sock, buf)
      # buf += '\n'
      fds = [sock]
      
      deadline = Time.now.to_f + 3 * config.polls_interval
      while deadline > Time.now.to_f and not buf.empty? do
        _, wr, ex = IO.select([], fds, fds, config.polls_interval)
        
        if ex and ex.any?
          raise IOError.new('send(): select() excepted')
        elsif wr
          while buf and not buf.empty? do
            begin
              sent = wr.first.send(buf, 0)
              buf = buf[sent, buf.size - sent]
            rescue Exception => e
              if [35, 36].include? e.errno 
                break
              else
                raise e
              end
            end
          end
        end
      end
      
      unless buf.empty?
        raise IOError.new('send() timed out')
      else
        return self
      end
    end
    
    def recv(sock)
      fds = [sock]
      buf = ''
      
      deadline = Time.now.to_f() + 3 * config.polls_interval
      while deadline > Time.now.to_f do
        rd, _, ex = IO.select(fds, [], fds, config.polls_interval)
        
        if ex and ex.any?
          raise IOError.new('send(): select() excepted')
        elsif rd
          while true do
            begin
              s = rd.first.recv_nonblock(256)
            rescue Exception => e
              if [35, 36].include? e.errno
                break
              else
                raise e
              end
            else
              if not s
                raise IOError.new('recv(): connection lost')
              else
                buf += s
              end
            end
          end
          
          break if buf.size > 0
        end
      end
      
      return buf[0, buf.size - 1] if buf.size > 0
      raise IOError.new('recv() timed out')
    end
    
    def call(cmd, data = {})
      data = {} if data.nil?
      data.merge!({:cmd => cmd, :version => config.api_version})
      
      request = data.to_json
      log('SEND', request.to_s)
      
      response = nil
      
      (0...1).each do
        # Locks other threads.
        # If another thread has already acquired the lock, this thread will be locked.
        @mutex.lock
        
        begin
          sock = connect
          send(sock, request)
          
          response = recv(sock)
        rescue Exception => e
          log('SEND', e.message)
          log('SEND', e.backtrace.join('\n'))
          close
        else
          # If no exception raised.
          break
        ensure
          @mutex.unlock
        end
        
      end
      
      if response.nil?
        msg = 'Connection timed out during API request'
        log('SEND', msg)
        
        raise Exception.new(msg)
      end
      
      log('RECV', response.to_s)
      
      begin
        response = JSON.load(response)
      rescue Exception => e
        raise Exception.new('Invalid API response')
      end
      
      if 0x00 < response['status'] and 0x10 > response['status']
        raise DeathByCaptcha::Errors::AccessDenied
      elsif 0xff == response['status']
        raise Exception.new('API server error occured')
      else
        return response
      end
      
    end
    
  end
  
  
  def self.socket_client(username, password, extra={})
    DeathByCaptcha::SocketClient.new(username, password, extra)
  end
  
end