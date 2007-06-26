use Test::More;

eval {
  require Test::Distribution;
};

if($@) {
  plan skip_all => 'Test::Distribution not installed';
} else {
  import Test::Distribution;
}

