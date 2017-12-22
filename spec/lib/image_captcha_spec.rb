require 'spec_helper'

username      = CREDENTIALS['username']
password      = CREDENTIALS['password']
path2         = './captchas/2.jpg' # path of the captcha (Coordinates API)
path3_grid    = './captchas/3-grid.jpg' # path of the grid (Image Group API)
path3_banner  = './captchas/3-banner.jpg' # path of the grid (Image Group API)
banner_text3  = 'Click all images with bananas'
token_params = {
  #proxy: "http://127.0.0.1:3128",
  #proxytype: "HTTP",
  googlekey: "6Ld2sf4SAAAAAKSgzs0Q13IZhY02Pyo31S2jgOB5",
  pageurl: "https://patrickhlauke.github.io/recaptcha/"
}

describe 'Solving an image based captcha' do
  before(:all) { @client = DeathByCaptcha.new(username, password, :http) }

  context 'Coordinates API' do
    describe '#decode!' do
      before(:all) { @captcha = @client.decode!(type: 2, path: path2) }
      it { expect(@captcha).to be_a(DeathByCaptcha::Captcha) }
      it { expect(@captcha.text).to match(/\A\[\[.*\]\]\Z/) }
      it { expect(@captcha.coordinates).to be_a(Array) }
      it { expect(@captcha.coordinates.size).to be > 0 }
      it 'expect coordinates to be valid' do
        @captcha.coordinates.each do |coordinate|
          expect(coordinate).to be_a(Array)
          expect(coordinate.size).to eq(2)
        end
      end
      it { expect(@captcha.is_correct).to be true }
      it { expect(@captcha.id).to be > 0 }
      it { expect(@captcha.id).to eq(@captcha.captcha) }
    end
  end

  context 'Image Group API' do
    describe '#decode!' do
      before(:all) do
        @captcha = @client.decode!(
          type: 3,
          path: path3_grid,
          banner: { path: path3_banner },
          banner_text: banner_text3
        )
      end
      it { expect(@captcha).to be_a(DeathByCaptcha::Captcha) }
      it { expect(@captcha.text).to match(/\A\[.*\]\Z/) }
      it { expect(@captcha.indexes).to be_a(Array) }
      it { expect(@captcha.indexes.size).to be > 0 }
      it 'expect indexes to be valid' do
        @captcha.indexes.each do |index|
          expect(index).to be_a(Numeric)
        end
      end
      it { expect(@captcha.is_correct).to be true }
      it { expect(@captcha.id).to be > 0 }
      it { expect(@captcha.id).to eq(@captcha.captcha) }
    end
  end

  context 'Token API' do
    describe '#decode!' do
      before(:all) do
        @captcha = @client.decode!(
          type: 4,
          token_params: token_params,
        )
      end
      it { expect(@captcha).to be_a(DeathByCaptcha::Captcha) }
      it { expect(@captcha.text).to eq(@captcha.token) }
      it { expect(@captcha.token).to match(/\A"?\S+"?\Z/) }
      it { expect(@captcha.token.size).to be > 30 }
      it { expect(@captcha.is_correct).to be true }
      it { expect(@captcha.id).to be > 0 }
      it { expect(@captcha.id).to eq(@captcha.captcha) }
    end
  end
end
