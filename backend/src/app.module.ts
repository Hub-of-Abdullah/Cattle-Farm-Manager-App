import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './auth/auth.module';
import { OwnersModule } from './owners/owners.module';
import { CattleModule } from './cattle/cattle.module';
import { ExpensesModule } from './expenses/expenses.module';
import { SalesModule } from './sales/sales.module';
import { FirmDepositsModule } from './firm-deposits/firm-deposits.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { ReportsModule } from './reports/reports.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (cfg: ConfigService) => ({
        type: 'postgres',
        host: cfg.get<string>('DB_HOST', 'localhost'),
        port: cfg.get<number>('DB_PORT', 5432),
        username: cfg.get<string>('DB_USERNAME', 'postgres'),
        password: cfg.get<string>('DB_PASSWORD', ''),
        database: cfg.get<string>('DB_NAME', 'cattle_farm'),
        autoLoadEntities: true,
        synchronize: cfg.get<string>('NODE_ENV') !== 'production',
      }),
    }),
    AuthModule,
    OwnersModule,
    CattleModule,
    ExpensesModule,
    SalesModule,
    FirmDepositsModule,
    DashboardModule,
    ReportsModule,
  ],
})
export class AppModule {}
