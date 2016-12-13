package Local::TCP::Calc::Server;

use strict;
use warnings;

use Local::TCP::Calc;
use Local::TCP::Calc::Server::Queue;
use Local::TCP::Calc::Server::Worker;
use Local::TCP::Calc::Server::Queue::Task

my $max_worker;
my $in_process = 0;

my $pids_master = {};
my $receiver_count = 0;
my $max_forks_per_task = 0;

sub REAPER {
	...
	# Функция для обработки сигнала CHLD
};
$SIG{CHLD} = \&REAPER;

sub start_server {
	my ($pkg, $port, %opts) = @_;
	$max_worker         = $opts{max_worker} // die "max_worker required"; 
	$max_forks_per_task = $opts{max_forks_per_task} // die "max_forks_per_task required";
	my $max_receiver    = $opts{max_receiver} // die "max_receiver required"; 
	my $max_queue_task  = $opts{max_queue_task} // die "max_queue_task required"; 

	my $server = IO::Socket::INET->new(
		LocalPort => '80',
		Type      => SOCK_STREAM,
		ReuseAddr => 1,
		Listen    => $max_receiver,)
	or die "Can't create server on port 80: $@ $/";
	
	my $q = Local::TCP::Calc::Server::Queue->new(max_task => $max_queue_task);
  	
	$q->init();
	
	# Начинаем accept-тить подключения
	while( my $client = $server->accept() ) {
		my $child = fork();
		if($child) {
			close $client;
			next;
		}
		if(defined $child) {
			close $server;
			# Проверяем, что количество принимающих форков не вышло за пределы допустимого ($max_receiver)
	        # Если все нормально отвечаем клиенту TYPE_CONN_OK() в противном случае TYPE_CONN_ERR()
			if(++$receiver_count <= $max_receiver) {
				warn "Can't say to user TYPE_CONN_ERR(), 'Exceeded the maximum number of forks'" 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						TYPE_CONN_ERR(), 'Exceeded the maximum number of forks'
					) != 2+length('Exceeded the maximum number of forks');
				close $client;
				$receiver_count--;
				exit;
			}
			warn "Can't say to user TYPE_CONN_OK(), 'OK'" 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						TYPE_CONN_OK(), 'OK'
					) != 2+length('OK');
			
			# В каждом форке читаем сообщение от клиента, анализируем его тип (TYPE_START_WORK(), TYPE_CHECK_WORK()) 
			# Не забываем проверять количество прочитанных/записанных байт из/в сеть
			sysread $client, $target, size;
			
			my ($msg_len, $msg_type, $msg) = unpack "CLa*",  # == $msg_len;
			unless(length($msg) == $msg_len) {
				syswrite $client, pack "CL/a*", TYPE_CONN_ERR(), 'Incorrect data size';
				close $client;
				exit;
			}
			
			# Если необходимо добавляем задание в очередь (проверяем получилось или нет) 
			if( $msg_type == TYPE_START_WORK() ) {
				my $id = $q->add($msg);
				unless ($id) {
					warn "Can't say to user STATUS_ERROR(), 'Can't add task in queue'" 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						STATUS_ERROR(), "Can't add task in queue"
					) != 2+length("Can't add task in queue"); 
					close $close;
					exit;
				}
				warn "Can't say to user $id, ''" 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						$id, ""
					) != 2+length("");
			}
			# Если пришли с проверкой статуса, получаем статус из очереди и отдаём клиенту
			# В случае если статус DONE или ERROR возвращаем на клиент содержимое файла с результатом выполнения
			# После того, как результат передан на клиент зачищаем файл с результатом
			elsif( $msg_type == TYPE_CHECK_WORK() ) {
				my $status = $q->get_status($msg);
				if ($status == STATUS_NEW() or $status == STATUS_WORK()) {
					my $task = $q->get($msg);
					warn "Can't say to user $status, '@{$task->status_time}'" 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						$status, $task->status_time
					) != 2+length($task->status_time));
				}
				elsif ($status == STATUS_DONE() or $status == STATUS_ERROR()) {
					my $task = $q->get($msg);
					if(open(my $fh, "<", $task->file)) {
						my @data = <$fh>;
					} else {
						$status = STATUS_ERROR();
						my @data = ($!);
					}
					warn "Can't say to user $status, '".join("\n", @data)."'"; 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						$status, ;
					) != 2+length(join("\n", @data));
					close($fh);
					unlink $task->file;
				} else {
					warn "Can't say to user STATUS_ERROR(), 'Wrong status'"; 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						STATUS_ERROR(), "Wrong status"
					) != 2+length("Wrong status");
					close $close;
					exit;
				}
			}
			close $client;
			$receiver_count--;
			exit;
		} else {
			warn "Can't say to user TYPE_CONN_ERR(), 'Server can't fork'"; 
					unless (syswrite $client, Local::TCP::Calc->pack_message(
						TYPE_CONN_ERR(), "Server can't fork"
					) != 2+length("Server can't fork");
			close $client;
			close $server;
			die "Can't fork: $!";
		}
	}
}

# Функция в которой стартует обработчик задания
# Должна следить за тем, что бы кол-во обработчиков не превышало мексимально разрешённого ($max_worker)
# Но и простаивать обработчики не должны
sub check_queue_workers {
	my $self = shift;
	my $q = shift;
	...
	# my $worker = Local::TCP::Calc::Server::Worker->new(...);
	# $worker->start(...);
	# $q->to_done ...
}

1;
