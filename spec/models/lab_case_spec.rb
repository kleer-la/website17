require 'spec_helper'
require './lib/models/lab_case'

describe LabCase do
  fixtures_dir = File.expand_path('../fixtures/lab_cases', __dir__)

  around do |example|
    LabCase.cases_dir = fixtures_dir
    LabCase.allow_drafts = false
    example.run
  ensure
    LabCase.cases_dir = nil
    LabCase.allow_drafts = nil
  end

  describe '.published' do
    it 'excludes drafts and sorts by order' do
      slugs = LabCase.published.map(&:slug)
      expect(slugs).to eq(%w[metric_full quote_full])
    end
  end

  describe '.find / .find_published' do
    it 'finds a published case by slug' do
      expect(LabCase.find('metric_full').title).to eq('Metric case title')
    end

    it 'hides drafts from find_published when drafts are not allowed' do
      expect(LabCase.find('draft')).not_to be_nil
      expect(LabCase.find_published('draft')).to be_nil
    end

    it 'shows drafts when drafts are allowed' do
      LabCase.allow_drafts = true
      expect(LabCase.find_published('draft')).not_to be_nil
    end

    it 'ignores slugs with path traversal or unexpected characters' do
      expect(LabCase.find('../secret')).to be_nil
      expect(LabCase.find('metric_full/../draft')).to be_nil
    end
  end

  describe '.aggregate_metrics_for_home' do
    it 'collects hero and secondary metrics with their source case' do
      metrics = LabCase.aggregate_metrics_for_home(limit: 4)
      expect(metrics.first).to eq(
        'value' => '95%', 'label' => 'de pedidos automatizados', 'source_case_slug' => 'metric_full'
      )
      expect(metrics.map { |m| m['value'] }).to include('+370')
    end

    it 'respects the limit' do
      expect(LabCase.aggregate_metrics_for_home(limit: 1).size).to eq(1)
    end
  end

  describe '.featured_testimonials' do
    it 'only returns cases flagged for the home page' do
      slugs = LabCase.featured_testimonials.map(&:slug)
      expect(slugs).to eq(['metric_full'])
    end
  end

  describe 'instance accessors' do
    let(:metric_case) { LabCase.find('metric_full') }
    let(:quote_case)  { LabCase.find('quote_full') }

    it 'exposes hero_metric / hero_quote appropriately' do
      expect(metric_case.hero_metric['value']).to eq('95%')
      expect(metric_case.hero_quote).to be_nil
      expect(quote_case.hero_quote['text']).to eq('Ahora gestiono todo en tiempo real')
    end

    it 'falls back to client_descriptor for client_label' do
      expect(quote_case.client_label).to eq('Un importador de mercadería.')
    end

    it 'renders the markdown body to HTML' do
      expect(metric_case.body_html).to include('<h2>El Desafío</h2>')
    end
  end
end
