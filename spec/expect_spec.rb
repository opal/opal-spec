describe '#expect' do
  it 'works with simple matchers' do
    expect(1).to eq(1)
  end

  it 'works with simple to_not matchers' do
    expect(1).to_not eq(2)
  end
end
