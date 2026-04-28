import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CattleController } from './cattle.controller';
import { CattleService } from './cattle.service';
import { Cattle } from './cattle.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Cattle])],
  controllers: [CattleController],
  providers: [CattleService],
  exports: [CattleService],
})
export class CattleModule {}
