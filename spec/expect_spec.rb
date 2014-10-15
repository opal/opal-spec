describe '#expect' do
  it 'works with simple matchers' do
    expect(1).to eq(1)
  end

  it 'works with simple to_not matchers' do
    expect(1).to_not eq(2)
  end

  it 'does not allow operator matchers' do
    proc {
      expect(2).to == 2
    }.should raise_error

    proc {
      expect(2).to_not == 2
    }.should raise_error
  end
end
