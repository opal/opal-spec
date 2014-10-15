describe 'Async helpers' do
  let(:foo) { 100 }

  before { @model = 200 }

  async 'can run examples async' do
    async { 1.should == 1 }
  end

  async 'can access let() and before() helpers' do
    async {
      foo.should eq(100)
      @model.should eq(200)
    }
  end

  async 'can finish running after a long delay' do
    obj = [1, 2, 3, 4]

    delay(1) {
      async { obj.should == [1, 2, 3, 4] }
    }
  end
end
