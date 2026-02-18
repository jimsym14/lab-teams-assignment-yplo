Rswag::Ui.configure do |c|
  # Λέμε στο UI να διαβάσει το αρχείο από τον public φάκελο
  c.swagger_endpoint '/swagger.yaml', 'Lab Portal API V1'
end