requires 'perl', '5.008005';

requires 'Net::Statsd::Client', '== 0.33';

on test => sub {
    requires 'Test::More', '0.96';
};
