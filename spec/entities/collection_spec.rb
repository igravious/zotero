require 'spec_helper'

describe Zotero::Entities::Collection do 
  let(:top_data) { JSON.parse(File.read('./spec/support/top_collections.json')) }
  let(:sub_data) { JSON.parse(File.read('./spec/support/sub_collections.json')) }
  let(:items_data) { JSON.parse(File.read('./spec/support/items.json')) }
  let(:api) { double 'api' }
  subject { described_class.new api, collection_data }

  context 'parent, no items' do
    let(:collection_data) { top_data.last }

    specify { expect(subject.name).to eq 'Digitality' }

    it 'should not bother loading items as there are none' do 
      expect(api).not_to receive(:get)
      items = subject.items
      expect(items).to be_empty
    end

    it 'should load child collections' do 
      expect(api).to receive(:get).with(
        "collections/#{top_data.last['key']}/collections"
      ).and_return(sub_data)

      collections = subject.collections

      expect(collections.size).to eq 2
    end
  end

  context 'child, has items, no children' do
    let(:collection_data) { sub_data.last }

    specify { expect(subject.name).to eq 'Interface' }

    it 'should not bother loading child collections as there are none' do 
      expect(api).not_to receive(:get)
      collections = subject.collections
      expect(collections).to be_empty
    end

    it 'should load items' do 
      expect(api).to receive(:get).with(
        "collections/#{sub_data.last['key']}/items"
      ).and_return(items_data)

      items = subject.items

      expect(items.size).to eq 25
    end
  end
end