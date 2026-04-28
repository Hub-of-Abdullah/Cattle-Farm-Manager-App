import {
  Controller, Get, Post, Delete,
  Param, Body, ParseIntPipe, UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { FirmDepositsService } from './firm-deposits.service';
import { CreateFirmDepositDto } from './dto/create-firm-deposit.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Firm Deposits')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('firm-deposits')
export class FirmDepositsController {
  constructor(private readonly service: FirmDepositsService) {}

  @Get()
  findAll() { return this.service.findAll(); }

  @Post()
  create(@Body() dto: CreateFirmDepositDto) { return this.service.create(dto); }

  @Delete(':id')
  async remove(@Param('id', ParseIntPipe) id: number) {
    await this.service.remove(id);
    return { message: 'Transaction deleted successfully' };
  }
}
