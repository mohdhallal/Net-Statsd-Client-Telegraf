use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::More;
use TestStatsd;
$TestStatsd::ALWAYS_SAMPLE = 1;

use_ok 'Net::Statsd::Client::Telegraf';

my $client = Net::Statsd::Client::Telegraf->new;

sends_ok { $client->increment("foo1") } qr/^foo1:1\|c$/, "increment";
sends_ok { $client->decrement("foo2") } qr/^foo2:-1\|c$/, "decrement";
sends_ok { $client->update("foo3", 42) } qr/^foo3:42\|c$/, "update";
sends_ok { $client->timing_ms("foo4", 1) } qr/^foo4:1\|ms$/, "timing";
sends_ok {
  my $timer = $client->timer("foo5");
  sleep 1;
  $timer->finish;
} qr/^foo5:[\d\.]+\|ms$/, "timer 2";

sends_ok { $client->increment("foo1", rate => 0.8, tags => { key => "value" } ) } qr/^foo1,key=value:1\|c\|\@0\.8$/, "increment";
sends_ok { $client->decrement("foo2", rate => 0.8, tags => { key => "value" }) } qr/^foo2,key=value:-1\|c\|\@0\.8$/, "decrement";
sends_ok { $client->update("foo3", 42, rate => 0.8, tags => { key => "value" }) } qr/^foo3,key=value:42\|c\|\@0\.8$/, "update";
sends_ok { $client->timing_ms("foo4", 1, rate => 0.8, tags => { key => "value" }) } qr/^foo4,key=value:1\|ms\|\@0\.8$/, "timing";
sends_ok {
  my $timer = $client->timer("foo5", rate => 0.8, tags => { key => "value" });
  sleep 1;
  $timer->finish;
} qr/^foo5,key=value:[\d\.]+\|ms$/, "timer 2"; #not sure why sampling is not there

$client = Net::Statsd::Client::Telegraf->new(sample_rate => 0.8, tags => { key => "value" });

sends_ok { $client->increment("foo1") } qr/^foo1,key=value:1\|c\|\@0\.8$/, "increment";
sends_ok { $client->decrement("foo2") } qr/^foo2,key=value:-1\|c\|\@0\.8$/, "decrement";
sends_ok { $client->update("foo3", 42) } qr/^foo3,key=value:42\|c\|\@0\.8$/, "update";
sends_ok { $client->timing_ms("foo4", 1) } qr/^foo4,key=value:1\|ms$/, "timing"; #not sure why sampling is not there
sends_ok {
  my $timer = $client->timer("foo5");
  sleep 1;
  $timer->finish;
} qr/^foo5,key=value:[\d\.]+\|ms$/, "timer 2"; #not sure why sampling is not there

done_testing;
