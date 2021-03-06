describe ProposalSearch do
  describe '#execute' do
    it "returns an empty list for no Proposals" do
      results = ProposalSearch.new.execute('')
      expect(results).to eq([])
    end

    it "returns the Proposal when searching by ID" do
      proposal = FactoryGirl.create(:proposal)
      results = ProposalSearch.new.execute(proposal.id.to_s)
      expect(results).to eq([proposal])
    end

    it "can operate on an a relation" do
      proposal = FactoryGirl.create(:proposal)
      relation = Proposal.where(id: proposal.id + 1)
      results = ProposalSearch.new(relation).execute(proposal.id.to_s)
      expect(results).to eq([])
    end

    it "returns an empty list for no matches" do
      FactoryGirl.create(:proposal)
      results = ProposalSearch.new.execute('asgsfgsfdbsd')
      expect(results).to eq([])
    end

    context Ncr::WorkOrder do
      [:project_title, :description, :vendor].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          work_order = FactoryGirl.create(:ncr_work_order, attr_name => 'foo')
          results = ProposalSearch.new.execute('foo')
          expect(results).to eq([work_order.proposal])
        end
      end
    end

    context Gsa18f::Procurement do
      [:product_name_and_description, :justification, :additional_info].each do |attr_name|
        it "returns the Proposal when searching by the ##{attr_name}" do
          procurement = FactoryGirl.create(:gsa18f_procurement, attr_name => 'foo')
          results = ProposalSearch.new.execute('foo')
          expect(results).to eq([procurement.proposal])
        end
      end
    end

    it "returns the Proposals by rank" do
      prop1 = FactoryGirl.create(:proposal, id: 12)
      work_order = FactoryGirl.create(:ncr_work_order, project_title: "12 rolly chairs for 1600 Penn Ave")
      prop2 = work_order.proposal
      prop3 = FactoryGirl.create(:proposal, id: 1600)

      searcher = ProposalSearch.new
      expect(searcher.execute('12')).to eq([prop1, prop2])
      expect(searcher.execute('1600')).to eq([prop3, prop2])
      expect(searcher.execute('12 rolly')).to eq([prop2])
    end
  end
end
