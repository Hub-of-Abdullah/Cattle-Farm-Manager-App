import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Reports')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('reports')
export class ReportsController {
  constructor(private readonly service: ReportsService) {}

  @Get('summary')
  getSummary() { return this.service.getSummary(); }

  @Get('per-owner')
  getPerOwner() { return this.service.getPerOwner(); }

  @Get('per-cattle')
  getPerCattle() { return this.service.getPerCattle(); }

  @Get('transactions')
  getTransactions() { return this.service.getTransactions(); }
}
