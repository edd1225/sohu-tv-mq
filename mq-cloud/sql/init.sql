-- ----------------------------
-- DATABASE structure for `mq-cloud`
-- ----------------------------
CREATE DATABASE IF NOT EXISTS `mq-cloud` DEFAULT CHARACTER SET utf8;

use `mq-cloud`;
-- ----------------------------
-- Table structure for `audit`
-- ----------------------------
DROP TABLE IF EXISTS `audit`;
CREATE TABLE `audit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户id',
  `type` tinyint(4) NOT NULL COMMENT '申请类型:0:新建TOPIC,1:修改TOPIC ,2:删除TOPIC ,3:新建消费者,4:删除消费者,5:重置offset,6:跳过堆积,7:关联生产者,8:关联消费者,9:成为管理员',
  `info` varchar(360) DEFAULT NULL COMMENT '申请描述',
  `status` tinyint(4) NOT NULL DEFAULT '0' COMMENT '0:等待审批,1:审批通过,2:驳回',
  `refuse_reason` varchar(360) DEFAULT NULL COMMENT '驳回理由',
  `auditor` varchar(64) DEFAULT NULL COMMENT '审计员(邮箱)',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核主表';

-- ----------------------------
-- Table structure for `audit_associate_consumer`
-- ----------------------------
DROP TABLE IF EXISTS `audit_associate_consumer`;
CREATE TABLE `audit_associate_consumer` (
  `uid` int(11) NOT NULL COMMENT '关联的用户ID',
  `aid` int(11) NOT NULL COMMENT '审核id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `cid` int(11) NOT NULL COMMENT 'consumer id',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核关联消费者相关表';

-- ----------------------------
-- Table structure for `audit_associate_producer`
-- ----------------------------
DROP TABLE IF EXISTS `audit_associate_producer`;
CREATE TABLE `audit_associate_producer` (
  `uid` int(11) NOT NULL COMMENT '关联的用户ID',
  `aid` int(11) NOT NULL COMMENT '审核id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `producer` varchar(64) NOT NULL COMMENT '关联的生产者名字',
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核关联生产者相关表';

-- ----------------------------
-- Table structure for `audit_consumer`
-- ----------------------------
DROP TABLE IF EXISTS `audit_consumer`;
CREATE TABLE `audit_consumer` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `consumer` varchar(64) NOT NULL COMMENT '消费者名字',
  `consume_way` int(4) NOT NULL DEFAULT '0' COMMENT '0:集群消费,1:广播消费',
  UNIQUE KEY `tid` (`tid`,`consumer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核消费者相关表';

-- ----------------------------
-- Table structure for `audit_consumer_delete`
-- ----------------------------
DROP TABLE IF EXISTS `audit_consumer_delete`;
CREATE TABLE `audit_consumer_delete` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `cid` int(11) NOT NULL COMMENT 'consumer id',
  `consumer` varchar(64) DEFAULT NULL COMMENT 'consumer名字',
  `topic` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核消费者删除相关表';

-- ----------------------------
-- Table structure for `audit_producer_delete`
-- ----------------------------
DROP TABLE IF EXISTS `audit_producer_delete`;
CREATE TABLE `audit_producer_delete` (
  `uid` int(11) NOT NULL,
  `aid` int(11) NOT NULL COMMENT '审核id',
  `pid` int(11) NOT NULL COMMENT 'userProducer id',
  `producer` varchar(64) DEFAULT NULL,
  `topic` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`aid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核用户与生产者组关系删除相关表';

-- ----------------------------
-- Table structure for `audit_reset_offset`
-- ----------------------------
DROP TABLE IF EXISTS `audit_reset_offset`;
CREATE TABLE `audit_reset_offset` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `consumer_id` int(11) DEFAULT NULL COMMENT 'consumer id',
  `offset` varchar(64) DEFAULT NULL COMMENT 'null:重置为最大offset,时间戳:重置为某时间点(yyyy-MM-dd#HH:mm:ss:SSS)'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核offset相关表';

-- ----------------------------
-- Table structure for `audit_topic`
-- ----------------------------
DROP TABLE IF EXISTS `audit_topic`;
CREATE TABLE `audit_topic` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `name` varchar(64) NOT NULL COMMENT 'topic名',
  `queue_num` int(11) NOT NULL COMMENT '队列长度',
  `producer` varchar(64) NOT NULL COMMENT '生产者名字',
  `ordered` int(4) NOT NULL DEFAULT '0' COMMENT '0:无序,1:有序',
  `qps` int(11) DEFAULT NULL COMMENT '消息量qps预估',
  `qpd` int(11) DEFAULT NULL COMMENT '一天消息量预估',
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核topic相关表';

-- ----------------------------
-- Table structure for `audit_topic_delete`
-- ----------------------------
DROP TABLE IF EXISTS `audit_topic_delete`;
CREATE TABLE `audit_topic_delete` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `topic` varchar(64) DEFAULT NULL COMMENT 'topic名字'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核topic删除相关表';

-- ----------------------------
-- Table structure for `audit_topic_update`
-- ----------------------------
DROP TABLE IF EXISTS `audit_topic_update`;
CREATE TABLE `audit_topic_update` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `queue_num` int(11) NOT NULL COMMENT '队列长度'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核topic更新相关表';

-- ----------------------------
-- Table structure for `audit_user_consumer_delete`
-- ----------------------------
DROP TABLE IF EXISTS `audit_user_consumer_delete`;
CREATE TABLE `audit_user_consumer_delete` (
  `aid` int(11) NOT NULL COMMENT '审核id',
  `uid` int(11) NOT NULL COMMENT '此消费者对应的用户',
  `ucid` int(11) NOT NULL COMMENT 'user_consumer id',
  `consumer` varchar(64) DEFAULT NULL,
  `topic` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='审核用户与消费者组关系删除相关表';

-- ----------------------------
-- Table structure for `broker_traffic`
-- ----------------------------
DROP TABLE IF EXISTS `broker_traffic`;
CREATE TABLE `broker_traffic` (
  `ip` varchar(16) NOT NULL COMMENT 'ip',
  `create_date` date NOT NULL COMMENT '数据收集天',
  `create_time` char(4) NOT NULL COMMENT '数据收集小时分钟,格式:HHMM',
  `cluster_id` int(11) NOT NULL COMMENT 'cluster_id',
  `put_count` int(11) NOT NULL DEFAULT '0' COMMENT '生产消息量',
  `put_size` int(11) NOT NULL DEFAULT '0' COMMENT '生产消息大小',
  `get_count` int(11) NOT NULL DEFAULT '0' COMMENT '消费消息量',
  `get_size` int(11) NOT NULL DEFAULT '0' COMMENT '消费消息大小',
  PRIMARY KEY (`ip`,`create_date`,`create_time`),
  KEY `time` (`create_date`,`cluster_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='broker流量表';

-- ----------------------------
-- Table structure for `client_version`
-- ----------------------------
DROP TABLE IF EXISTS `client_version`;
CREATE TABLE `client_version` (
  `topic` varchar(255) NOT NULL,
  `client` varchar(255) NOT NULL,
  `role` tinyint(4) NOT NULL COMMENT '1:producer,2:consumer',
  `version` varchar(255) NOT NULL,
  `create_date` date NOT NULL,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  UNIQUE KEY `topic` (`topic`,`client`,`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='topic客户端版本';

-- ----------------------------
-- Table structure for `cluster`
-- ----------------------------
DROP TABLE IF EXISTS `cluster`;
CREATE TABLE `cluster` (
  `id` int(11) NOT NULL COMMENT '集群id，也会作为ns发现的一部分',
  `name` varchar(64) NOT NULL COMMENT '集群名',
  `vip_channel_enabled` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否开启vip通道, 1:开启, 0:关闭, rocketmq 4.x版本默认开启',
  `online` tinyint(4) NOT NULL DEFAULT '0' COMMENT '是否为线上集群, 1:是, 0:否, 线上集群会开启流量抓取',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='集群表';

-- ----------------------------
-- Table structure for `common_config`
-- ----------------------------
DROP TABLE IF EXISTS `common_config`;
CREATE TABLE `common_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(64) DEFAULT NULL COMMENT '配置key',
  `value` varchar(1024) NOT NULL COMMENT '配置值',
  `comment` varchar(256) DEFAULT '' COMMENT '备注',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `consumer`
-- ----------------------------
DROP TABLE IF EXISTS `consumer`;
CREATE TABLE `consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `name` varchar(64) NOT NULL COMMENT 'consumer名',
  `consume_way` int(4) NOT NULL DEFAULT '0' COMMENT '0:集群消费,1:广播消费',
  `create_date` date NOT NULL,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `tid` (`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='消费者表';

-- ----------------------------
-- Table structure for `consumer_block`
-- ----------------------------
DROP TABLE IF EXISTS `consumer_block`;
CREATE TABLE `consumer_block` (
  `csid` int(11) DEFAULT NULL COMMENT 'consumer_stat id',
  `instance` varchar(255) DEFAULT NULL COMMENT 'consumer instance_id',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `broker` varchar(255) DEFAULT NULL COMMENT 'broker',
  `qid` int(11) DEFAULT NULL COMMENT 'qid',
  `block_time` bigint(20) DEFAULT NULL COMMENT '毫秒=当前时间-最新消费时间',
  `offset_moved_times` int(11) DEFAULT '0' COMMENT 'offset moved times',
  `offset_moved_time` bigint(20) DEFAULT NULL COMMENT 'offset moved msg store time',
  UNIQUE KEY `csid` (`csid`,`broker`,`qid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `consumer_stat`
-- ----------------------------
DROP TABLE IF EXISTS `consumer_stat`;
CREATE TABLE `consumer_stat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `consumer_group` varchar(255) DEFAULT NULL COMMENT 'consumer group',
  `topic` varchar(255) DEFAULT NULL COMMENT 'host',
  `updatetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `undone_msg_count` int(11) DEFAULT NULL COMMENT '未消费的消息量',
  `undone_1q_msg_count` int(11) DEFAULT NULL COMMENT '单队列未消费的最大消息量',
  `undone_delay` bigint(20) DEFAULT NULL COMMENT '毫秒=broker最新消息存储时间-最新消费时间',
  `sbscription` varchar(255) DEFAULT NULL COMMENT '订阅关系,如果一个group订阅不同的topic,在这里会有体现',
  PRIMARY KEY (`id`),
  UNIQUE KEY `consumer_group` (`consumer_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `consumer_traffic`
-- ----------------------------
DROP TABLE IF EXISTS `consumer_traffic`;
CREATE TABLE `consumer_traffic` (
  `consumer_id` int(11) NOT NULL DEFAULT '0' COMMENT 'consumer id',
  `create_date` date NOT NULL COMMENT '数据收集天',
  `create_time` char(4) NOT NULL COMMENT '数据收集小时分钟,格式:HHMM',
  `count` int(11) DEFAULT NULL COMMENT 'topic put times',
  `size` int(11) DEFAULT NULL COMMENT 'topic put size',
  PRIMARY KEY (`consumer_id`,`create_date`,`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='消费者流量表';

-- ----------------------------
-- Table structure for `feedback`
-- ----------------------------
DROP TABLE IF EXISTS `feedback`;
CREATE TABLE `feedback` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户id',
  `content` text NOT NULL COMMENT '反馈内容',
  `create_date` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='反馈表';

-- ----------------------------
-- Table structure for `need_warn_config`
-- ----------------------------
DROP TABLE IF EXISTS `need_warn_config`;
CREATE TABLE `need_warn_config` (
  `oKey` varchar(64) NOT NULL COMMENT '报警频率的key（type_topic_group）',
  `times` int(11) NOT NULL COMMENT '次数',
  `update_time` bigint(13) NOT NULL COMMENT '计时起始时间时间',
  UNIQUE KEY `key` (`oKey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='报警频率表';

-- ----------------------------
-- Table structure for `notice`
-- ----------------------------
DROP TABLE IF EXISTS `notice`;
CREATE TABLE `notice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` varchar(512) NOT NULL COMMENT '通知内容',
  `status` tinyint(4) NOT NULL COMMENT '0:无效,1:有效',
  `create_date` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='通知表';

-- ----------------------------
-- Table structure for `producer_stat`
-- ----------------------------
DROP TABLE IF EXISTS `producer_stat`;
CREATE TABLE `producer_stat` (
  `total_id` int(11) NOT NULL COMMENT 'producer_total_stat id',
  `broker` varchar(20) NOT NULL COMMENT 'broker',
  `max` int(11) NOT NULL COMMENT '最大耗时',
  `avg` double NOT NULL COMMENT '平均耗时',
  `count` int(11) NOT NULL COMMENT '调用次数',
  `exception` text COMMENT '异常记录',
  KEY `total_id` (`total_id`,`broker`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生产者统计';

-- ----------------------------
-- Table structure for `producer_total_stat`
-- ----------------------------
DROP TABLE IF EXISTS `producer_total_stat`;
CREATE TABLE `producer_total_stat` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `producer` varchar(255) NOT NULL COMMENT 'producer',
  `client` varchar(20) NOT NULL COMMENT 'client',
  `percent90` int(11) NOT NULL COMMENT '耗时百分位90',
  `percent99` int(11) NOT NULL COMMENT '耗时百分位99',
  `avg` double NOT NULL COMMENT '平均耗时',
  `count` int(11) NOT NULL COMMENT '调用次数',
  `create_date` int(11) NOT NULL COMMENT '创建日期',
  `create_time` char(4) NOT NULL COMMENT '创建分钟,格式:HHMM',
  `stat_time` int(11) NOT NULL COMMENT '统计时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `producer` (`producer`,`stat_time`,`client`),
  KEY `create_date` (`create_date`,`producer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='生产者总体统计';

-- ----------------------------
-- Table structure for `server`
-- ----------------------------
DROP TABLE IF EXISTS `server`;
CREATE TABLE `server` (
  `ip` varchar(16) NOT NULL COMMENT 'ip',
  `host` varchar(255) DEFAULT NULL COMMENT 'host',
  `nmon` varchar(255) DEFAULT NULL COMMENT 'nmon version',
  `cpus` tinyint(4) DEFAULT NULL COMMENT 'logic cpu num',
  `cpu_model` varchar(255) DEFAULT NULL COMMENT 'cpu 型号',
  `dist` varchar(255) DEFAULT NULL COMMENT '发行版信息',
  `kernel` varchar(255) DEFAULT NULL COMMENT '内核信息',
  `ulimit` varchar(255) DEFAULT NULL COMMENT 'ulimit -n,ulimit -u',
  `updatetime` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `server_stat`
-- ----------------------------
DROP TABLE IF EXISTS `server_stat`;
CREATE TABLE `server_stat` (
  `ip` varchar(16) NOT NULL COMMENT 'ip',
  `cdate` date NOT NULL COMMENT '数据收集天',
  `ctime` char(4) NOT NULL COMMENT '数据收集小时分钟',
  `cuser` float DEFAULT NULL COMMENT '用户态占比',
  `csys` float DEFAULT NULL COMMENT '内核态占比',
  `cwio` float DEFAULT NULL COMMENT 'wio占比',
  `c_ext` text COMMENT '子cpu占比',
  `cload1` float DEFAULT NULL COMMENT '1分钟load',
  `cload5` float DEFAULT NULL COMMENT '5分钟load',
  `cload15` float DEFAULT NULL COMMENT '15分钟load',
  `mtotal` float DEFAULT NULL COMMENT '总内存,单位M',
  `mfree` float DEFAULT NULL COMMENT '空闲内存',
  `mcache` float DEFAULT NULL COMMENT 'cache',
  `mbuffer` float DEFAULT NULL COMMENT 'buffer',
  `mswap` float DEFAULT NULL COMMENT 'cache',
  `mswap_free` float DEFAULT NULL COMMENT 'cache',
  `nin` float DEFAULT NULL COMMENT '网络入流量 单位K/s',
  `nout` float DEFAULT NULL COMMENT '网络出流量 单位k/s',
  `nin_ext` text COMMENT '各网卡入流量详情',
  `nout_ext` text COMMENT '各网卡出流量详情',
  `tuse` int(11) DEFAULT NULL COMMENT 'tcp estab连接数',
  `torphan` int(11) DEFAULT NULL COMMENT 'tcp orphan连接数',
  `twait` int(11) DEFAULT NULL COMMENT 'tcp time wait连接数',
  `dread` float DEFAULT NULL COMMENT '磁盘读速率 单位K/s',
  `dwrite` float DEFAULT NULL COMMENT '磁盘写速率 单位K/s',
  `diops` float DEFAULT NULL COMMENT '磁盘io速率 交互次数/s',
  `dbusy` float DEFAULT NULL COMMENT '磁盘io带宽使用百分比',
  `d_ext` text COMMENT '磁盘各分区占比',
  `dspace` text COMMENT '磁盘各分区空间使用率',
  PRIMARY KEY (`ip`,`cdate`,`ctime`),
  KEY `cdate` (`cdate`,`ctime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `shedlock`
-- ----------------------------
DROP TABLE IF EXISTS `shedlock`;
CREATE TABLE `shedlock` (
  `name` varchar(64) NOT NULL DEFAULT '',
  `lock_until` timestamp(3) NULL DEFAULT NULL,
  `locked_at` timestamp(3) NULL DEFAULT NULL,
  `locked_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for `topic`
-- ----------------------------
DROP TABLE IF EXISTS `topic`;
CREATE TABLE `topic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cluster_id` int(11) NOT NULL COMMENT 'cluster id',
  `name` varchar(64) NOT NULL COMMENT 'topic名',
  `queue_num` int(11) NOT NULL COMMENT '队列长度',
  `ordered` int(4) NOT NULL DEFAULT '0' COMMENT '0:无序,1:有序',
  `count` int(11) DEFAULT NULL COMMENT 'topic put times',
  `create_date` date NOT NULL,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='topic表';

-- ----------------------------
-- Table structure for `topic_traffic`
-- ----------------------------
DROP TABLE IF EXISTS `topic_traffic`;
CREATE TABLE `topic_traffic` (
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `create_date` date NOT NULL COMMENT '数据收集天',
  `create_time` char(4) NOT NULL COMMENT '数据收集小时分钟,格式:HHMM',
  `count` int(11) DEFAULT NULL COMMENT 'topic put times',
  `size` int(11) DEFAULT NULL COMMENT 'topic put size',
  PRIMARY KEY (`tid`,`create_date`,`create_time`),
  KEY `time` (`create_date`,`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='topic流量表';

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) DEFAULT NULL COMMENT '用户名',
  `email` varchar(64) NOT NULL COMMENT '邮箱',
  `mobile` varchar(16) DEFAULT NULL COMMENT '手机',
  `type` int(4) NOT NULL DEFAULT '0' COMMENT '0:普通用户,1:管理员',
  `create_date` date NOT NULL,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `receive_notice` int(4) NOT NULL DEFAULT '0' COMMENT '是否接收各种通知,0:不接收,1:接收',
  `password` char(41) DEFAULT NULL COMMENT '登录方式采用用户名密码验证时使用',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户表';

-- ----------------------------
-- Table structure for `user_consumer`
-- ----------------------------
DROP TABLE IF EXISTS `user_consumer`;
CREATE TABLE `user_consumer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `consumer_id` int(11) DEFAULT NULL COMMENT 'consumer id',
  PRIMARY KEY (`id`),
  KEY `t_c` (`tid`,`consumer_id`),
  KEY `u_t` (`uid`,`tid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户与消费者关系表';

-- ----------------------------
-- Table structure for `user_message`
-- ----------------------------
DROP TABLE IF EXISTS `user_message`;
CREATE TABLE `user_message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户id',
  `message` varchar(512) NOT NULL COMMENT '消息内容',
  `status` tinyint(4) NOT NULL COMMENT '0:未读,1:已读',
  `create_date` datetime NOT NULL,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户消息表';

-- ----------------------------
-- Table structure for `user_producer`
-- ----------------------------
DROP TABLE IF EXISTS `user_producer`;
CREATE TABLE `user_producer` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL COMMENT '用户id',
  `tid` int(11) NOT NULL COMMENT 'topic id',
  `producer` varchar(64) NOT NULL COMMENT 'producer名',
  PRIMARY KEY (`id`),
  KEY `t_p` (`tid`,`producer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='用户与生产者关系表';

-- ----------------------------
-- Table structure for `warn_config`
-- ----------------------------
DROP TABLE IF EXISTS `warn_config`;
CREATE TABLE `warn_config` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) DEFAULT '0' COMMENT '用户id，为空时代表默认所有（仅一条默认记录）',
  `topic` varchar(64) DEFAULT '' COMMENT 'topic名，为空时代表默认所有（仅一条默认记录）',
  `accumulate_time` int(11) DEFAULT '300000' COMMENT '堆积时间',
  `accumulate_count` int(11) DEFAULT '10000' COMMENT '堆积数量',
  `block_time` int(11) DEFAULT '10000' COMMENT '堵塞时间',
  `consumer_fail_count` int(11) DEFAULT '10' COMMENT '消费失败数量',
  `ignore_topic` varchar(500) DEFAULT '' COMMENT '堆积报警忽略的topic名，逗号分隔',
  `warn_unit_time` int(4) DEFAULT '1' COMMENT '报警频率的单位时间，单位小时',
  `warn_unit_count` int(4) DEFAULT '2' COMMENT '报警频率在单位时间的次数',
  `ignore_warn` int(4) DEFAULT '0' COMMENT '0:接收所有报警,1:不接收所有报警，此字段优先级最高',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='报警阈值配置表';

-- ----------------------------
-- Table structure for `name_server`
-- ----------------------------
DROP TABLE IF EXISTS `name_server`;
CREATE TABLE `name_server` (
  `cid` int(11) NOT NULL COMMENT '集群id',
  `addr` varchar(255) NOT NULL COMMENT 'name server 地址',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  UNIQUE KEY `cid` (`cid`,`addr`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='name server表';

-- ----------------------------
-- user init
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'admin', 'admin@admin.com', '18688888888', '1', '2018-10-01', '2018-10-01 09:49:00', '1', password('admin'));

-- ----------------------------
-- common_config init
-- ----------------------------
INSERT INTO `common_config` VALUES ('1', 'domain', '127.0.0.1:8080', 'mqcloud的域名');
INSERT INTO `common_config` VALUES ('5', 'serverUser', 'mqcloud', '服务器 ssh 用户');
INSERT INTO `common_config` VALUES ('6', 'serverPassword', '9j7t4SDJOIusddca+Mzd6Q==', '服务器 ssh 密码');
INSERT INTO `common_config` VALUES ('7', 'serverPort', '22', '服务器 ssh 端口');
INSERT INTO `common_config` VALUES ('8', 'serverConnectTimeout', '6000', '服务器 ssh 链接建立超时时间');
INSERT INTO `common_config` VALUES ('9', 'serverOPTimeout', '12000', '服务器 ssh 操作超时时间');
INSERT INTO `common_config` VALUES ('10', 'ciperKey', 'DJs32jslkdghDSDf', '密码助手的key');
INSERT INTO `common_config` VALUES ('12', 'operatorContact', '[{\"name\":\"admin\",\"phone\":\"010-1234\",\"mobile\":\"18688888888\",\"qq\":\"88888888\",\"email\":\"admin@admin.com\"}]', '运维人员json');

-- ----------------------------
-- warn_config init
-- ----------------------------
INSERT INTO `warn_config` VALUES ('1', '0', '', '300000', '10000', '10000', '10', '', '1', '2', '0');

-- ----------------------------
-- notice init
-- ----------------------------
INSERT INTO `notice` (`content`, `status`, `create_date`) VALUES ('欢迎您使用MQCloud，为了更好为您的服务，请花一分钟时间看下快速指南，如果有任何问题，欢迎联系我们^_^', 1, now());

-- ----------------------------
-- user message init
-- ----------------------------
INSERT INTO `user_message` (`uid`, `message`, `status`, `create_date`) VALUES (1, 'Hello！Welcome to MQCloud！', 0, now());

-- ----------------------------
-- update for user password init for 1.1.RELEASE
-- ----------------------------
alter table user modify column `password` varchar(256) COMMENT '登录方式采用用户名密码验证时使用';
update user set `password` = '21232f297a57a5a743894a0e4a801fc3' where email = 'admin@admin.com';
delete from `common_config` where `key` in ('nexusDomain','alertClass','loginClass','ticketKey','clientArtifactId','producerClass','consumerClass');
