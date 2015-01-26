require 'spec_helper'

username    = CREDENTIALS['username']
password    = CREDENTIALS['password']
captcha_id  = CREDENTIALS['captcha_id']
image64     = Base64.encode64(File.open('captchas/1.png', 'rb').read)

describe DeathByCaptcha::Client do
  describe '.create' do
    context 'http' do
      let(:client) { DeathByCaptcha.new(username, password, :http) }
      it { expect(client).to be_a(DeathByCaptcha::Client::HTTP) }
    end

    context 'socket' do
      let(:client) { DeathByCaptcha.new(username, password, :socket) }
      it { expect(client).to be_a(DeathByCaptcha::Client::Socket) }
    end

    context 'default' do
      let(:client) { DeathByCaptcha.new(username, password) }
      it { expect(client).to be_a(DeathByCaptcha::Client::Socket) }
    end

    context 'other' do
      it { expect {
          DeathByCaptcha.new(username, password, :other)
        }.to raise_error(DeathByCaptcha::InvalidClientConnection)
      }
    end
  end

  context 'http' do
    subject(:client) { DeathByCaptcha.new(username, password, :http) }

    describe '#load_captcha' do
      it { expect(client.send(:load_captcha, url: 'http://bit.ly/1xXZcKo')).to eq(image64) }
      it { expect(client.send(:load_captcha, path: 'captchas/1.png')).to eq(image64) }
      it { expect(client.send(:load_captcha, file: File.open('captchas/1.png', 'rb'))).to eq(image64) }
      it { expect(client.send(:load_captcha, raw: File.open('captchas/1.png', 'rb').read)).to eq(image64) }
      it { expect(client.send(:load_captcha, raw64: image64)).to eq(image64) }
      it { expect(client.send(:load_captcha, other: nil)).to eq('') }
    end
  end
end

shared_examples 'a client' do
  describe '#captcha' do
    before(:all) { @captcha = @client.captcha(captcha_id) }
    it { expect(@captcha).to be_a(DeathByCaptcha::Captcha) }
    it { expect(@captcha.text.size).to be > 0 }
    it { expect([true, false]).to include(@captcha.is_correct) }
    it { expect(@captcha.id).to be > 0 }
    it { expect(@captcha.id).to eq(@captcha.captcha) }
  end

  describe '#user' do
    before(:all) { @user = @client.user() }
    it { expect(@user).to be_a(DeathByCaptcha::User) }
    it { expect([true, false]).to include(@user.is_banned) }
    it { expect(@user.balance).to be > 0 }
    it { expect(@user.rate).to be > 0 }
    it { expect(@user.id).to eq(@user.user) }
  end

  describe '#status' do
    before(:all) { @status = @client.status() }
    it { expect(@status).to be_a(DeathByCaptcha::ServerStatus) }
    it { expect(@status.todays_accuracy).to be > 0 }
    it { expect(@status.solved_in).to be > 0 }
    it { expect([true, false]).to include(@status.is_service_overloaded) }
  end

  describe '#decode!' do
    before(:all) { @captcha = @client.decode!(raw64: image64) }
    it { expect(@captcha).to be_a(DeathByCaptcha::Captcha) }
    it { expect(@captcha.text).to eq 'infosimples' }
    it { expect(@captcha.is_correct).to be true }
    it { expect(@captcha.id).to be > 0 }
    it { expect(@captcha.id).to eq(@captcha.captcha) }
  end
end

describe DeathByCaptcha::Client::HTTP do
  it_behaves_like 'a client' do
    before(:all) { @client = DeathByCaptcha.new(username, password, :http) }
  end
end

describe DeathByCaptcha::Client::Socket do
  it_behaves_like 'a client' do
    before(:all) { @client = DeathByCaptcha.new(username, password, :socket) }
  end
end
